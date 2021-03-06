$regexGoudyOlSt = [regex]'(GoudyOlSt BT)';
$regexLayoutBlock = [regex]'\\layout\s*{';
$regexPageHeight = [regex]'(?<=paper-height\s*=\s*)\d*(?:\.\d*)?\\in';
$regexMargin = [regex]'(?<=(top|bottom)-margin\s*=\s*)\d*(?:\.\d*)?\\in';
$regexTopMargin = [regex]'(?<=top-margin\s*=\s*)\d*(?:\.\d*)?\\in';
$regexInnerMargin = [regex]'(?<=inner-margin\s*=\s*)\d*(?:\.\d*)?\\in';
$regexOuterMargin = [regex]'(?<=outer-margin\s*=\s*)\d*(?:\.\d*)?\\in';
$regexStaffSize = [regex]'(?<!^\s*%.*#\(set-global-staff-size\s+)(?<=#\(set-global-staff-size\s+)\d*(?:\.\d*)?';
$regexSecondStaff = [regex]'(?<!^\s*%.*"Garamond Premier Pro" \(/ )(?<="Garamond Premier Pro" \(/ )\d*(?:\.\d*)?';
$regexAbsFont85 = [regex]'(?<=\\abs-fontsize\s+#)8\.5';
$regexAbsFont15 = [regex]'(?<=\\abs-fontsize\s+#)15';
$regexAbsFont105 = [regex]'(?<=\\abs-fontsize\s+#)10\.5';
$regexAbsFont9 = [regex]'(?<=\\abs-fontsize\s+#)9';
$regex69 = [regex]'(\s|^)%6x9\s*';
$regexWithClause = [regex]'(?<=\\new\s+Lyrics\s*(=\s+"\w+"\s*)?)\\with\s*{[^}]*}\s+';
$regexDropLyrics = [regex]'\\dropLyrics';

$files = (ls -filter *.ly);
foreach ($_ in $files) {
  if($_.Name -eq 'Util.ly') {
    continue;
  }
  echo $_.Name
  $f = Get-Content $_ -Encoding UTF8;
  $f = $f -replace $regexWithClause,"";
  $f = $f -replace $regexDropLyrics,"% \\dropLyrics";
  $f = $f -replace $regexGoudyOlSt,"Garamond Premier Pro";
  $f = $f -replace $regexLayoutBlock,"\layout {
\context {
  \Lyrics
  \override LyricText #'font-size = #1.3
  \override VerticalAxisGroup #'staff-affinity = #0
}";

#reverse order of lyrics
  $lnum = 0;
  $lyricsBegin = -10;
  $lyricsRun = $false;
  while($lnum -lt $f.length) {
    $l = $f[$lnum];
    if($l -match '\\new Lyrics') {
        if(!$lyricsRun) {
            $lyricsRun = $true;
            $lyricsBegin = $lnum;
        }
    } else {
        if($lyricsRun) {
            if(($lnum - $lyricsBegin) -gt 1) {
                $lyrics = $f[$lyricsBegin .. ($lnum-1)];
                [array]::Reverse($lyrics);
                $newl = 0;
                while($newl -lt $lyrics.length) {
                    $f[$newl + $lyricsBegin] = $lyrics[$newl];
                    ++$newl;
                }
            }
            $lyricsRun = $false;
        }
    }
    ++$lnum;
  }
  $content = $f -replace $regex69,'$1';
  $content | out-file ("test\" + $_.Name) -Encoding UTF8;
}