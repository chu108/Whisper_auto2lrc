# ����Ҫת�����ļ���·��
$folderPath = "R:"

# ��ȡҪת����������Ƶ�ļ�
$audioFiles = Get-ChildItem $folderPath -Recurse -Include "*.mp3", "*.wav"

# ���ý�������ʼֵ
$i = 0

# ����ÿ����Ƶ�ļ�������ת��
foreach ($file in $audioFiles) {
    # ���½�����
    Write-Progress -Activity "Converting audio files..." -Status "Processing file $($file.Name) ($($i+1) of $($audioFiles.Count))" -PercentComplete (($i+1)/$audioFiles.Count*100)
    
    # ִ��Whisper�����Ƶת��Ϊ�ı�
    whisper --model small --language ja $file.FullName
    
    # ��ȡ��Ӧ��.srt�ļ�������Python������ת��Ϊ.lrc�ļ�
    $srtFile = Get-ChildItem $file.DirectoryName -Include "*.srt" -Recurse | Where-Object { $_.Name -match $file.BaseName }
    if ($srtFile) {
        $lrcFile = $srtFile.FullName.Replace(".srt", ".lrc")
        & python "R:/srt_to_lrc.py" $srtFile.FullName $lrcFile
    }
    
    # ɾ����Whisper���ɵ��ļ�
    $whisperFiles = Get-ChildItem $file.DirectoryName -Include "*.json", "*.tsv", "*.txt", "*.vtt" -Recurse | Where-Object { $_.Name -match $file.BaseName }
    foreach ($whisperFile in $whisperFiles) {
        Remove-Item $whisperFile.FullName -Force
    }
    
    # ���ӽ���������
    $i++
}

# ���½�������ָʾת�������
Write-Progress -Activity "Converting audio files..." -Status "Conversion completed." -Completed