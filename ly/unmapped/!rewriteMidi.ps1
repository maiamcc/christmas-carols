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
$regexTitle = [regex]'(?<=title = \\markup{\\override #''\(font-name . "Garamond Premier Pro Semibold"\){ \\abs-fontsize #\d+(?:\.\d*)? \\smallCapsOldStyle")[^"]*(?=")';
$regexPrintAllHeaders = [regex]'(?<=print-all-headers\s+=\s+##)t';
$regexraggedLstBottom = [regex]'(?<=ragged-last-bottom\s+=\s+##)f';
$regexTempo = [regex]'\\tempo\s+\d+\s+=\s+\d+';
$regex69 = [regex]'(\s|^)%6x9\s*';
$defaultMidiBlock = '  \midi {
    \tempo 4 = 90
    \set Staff.midiInstrument = "flute"
  
    \context {
      \Voice
      \remove "Dynamic_performer"
    }
  }
}';
Function getBlock([string]$haystack, [long]$index) {
    $open = 0;
    $pos = $haystack.IndexOf('{',$index);
    while($pos -ge 0) {
        if($haystack[$pos] -eq '{') {
            $open++;
        } else {
            $open--;
        }
        if($open -eq 0) {
            return $haystack.Substring($index, $pos + 1 - $index);
        }
        $pos = $haystack.IndexOfAny("{}",$pos+1)
    }
    return '';
}
Function MergeHeaders([string]$header1, [string]$header2) {
    if($header1.Length -eq 0) {
        return $header2;
    }
    return $header1.Substring(0, $header1.length - 1) + $header2.Substring($header2.indexOf('{') + 1);
}

$files = (ls -filter *.ly);
$i = 0;
foreach ($_ in $files) {
  echo $_.Name
  $content = Get-Content $_ -Encoding UTF8 -Raw;
  if($content.indexOf('\repeat volta') -ge 0) {
    $pos = $content.IndexOf('\score',$currentBeginIndex);
    if($pos -ge 0) {
        $scoreBlock = GetBlock $content $pos;
        $midiPos = $scoreBlock.IndexOf('\midi');
        if($midiPos -lt 0) {
            continue;
        }
        $midiBlock = GetBlock $scoreBlock $midiPos;
        
        $layoutPos = $scoreBlock.IndexOf('\layout');
        if($layoutPos -lt 0) {
            continue;
        }
        $layoutBlock = GetBlock $scoreBlock $layoutPos;
        $replaceScore = $scoreBlock.Replace($midiBlock,'') + "`n`n\score {`n  \unfoldRepeats`n" + $scoreBlock.Substring($scoreBlock.IndexOf('{')+1).Replace($layoutBlock,'');
        
        $newContent = $content.Replace($scoreBlock,$replaceScore);
        $newContent | out-file ($_) -Encoding UTF8;
    }
  }
}