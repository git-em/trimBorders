#               trimBorders.praat
#                   v. 0.6
#
# Simultaneously trims audio and TextGrid borders

procedure refreshVars
    select TextGrid 'filename$'
    numIntervals = Get number of intervals... 'tier'
    textgridEndTime = Get end time
endproc

procedure refreshObjNames
    select TextGrid 'filename$'_part
    Rename... 'filename$'
    select Sound 'filename$'_part
    Rename... 'filename$'
endproc


form Tell me what to trim...
    word    filename
    integer tier            0
    integer skip_beginning  0
    integer beginning       0
    integer skip_end        0
    integer end             0
    boolean remove_original 0
    boolean debug           0
endform

if beginning <= 0 && end <= 0
    exit You want me to do nothing?

elsif beginning <= 0 && skip_beginning > 0
    exit No skipping without trimming!

elsif end <= 0 && skip_end > 0
    exit No skipping without trimming!

else
    if remove_original = 0
        select TextGrid 'filename$'
        Rename... 'filename$' originalTmp
        Copy... 'filename$' originalTmp
        Rename... 'filename$'
        select Sound 'filename$'
        Rename... 'filename$' originalTmp
        Copy... 'filename$' originalTmp
        Rename... 'filename$'
    endif

@refreshVars 

    if skip_beginning > 0
        skipBegLeftPoint = Get end point... 'tier' 'skip_beginning'
        Extract part... 0 'skipBegLeftPoint' "no"
        Rename... skipBegLeftObj

        select TextGrid 'filename$'
        skipBegRightPoint = Get end point... 'tier' 'skip_beginning' + 'beginning'
        Extract part... 'skipBegRightPoint' 'textgridEndTime' 'no'
        Rename... skipBegRightObj

        selectObject: "TextGrid skipBegLeftObj", "TextGrid skipBegRightObj"
        Concatenate
        if end > 0
            Rename... 'filename$' part
        else
            Rename... 'filename$' trimmed
        endif

        removeObject: "TextGrid " + filename$

        if debug = 0
            removeObject: "TextGrid skipBegLeftObj", "TextGrid skipBegRightObj" 
        endif

        ### WAV skip beginning
        select Sound 'filename$'
        View & Edit
        editor: "Sound " + filename$
        Move cursor to... 'skipBegLeftPoint'
        Move begin of selection by... 'skipBegRightPoint' - 'skipBegLeftPoint'
        Cut
        Close
        endeditor
        if end > 0
            Rename... 'filename$' part
        else
            Rename... 'filename$' trimmed
        endif
    endif


    if skip_end > 0

        if skip_beginning > 0
            @refreshObjNames
            @refreshVars
        endif

        skipEndLeftPoint = Get end point... 'tier' 'numIntervals' - 'skip_end' - 'end'
        Extract part... 0 'skipEndLeftPoint' "no"
        Rename... skipEndLeftObj

        select TextGrid 'filename$'
        skipEndRightPoint = Get end point... 'tier' 'numIntervals' - 'skip_end'
        Extract part... 'skipEndRightPoint' 'textgridEndTime' "no"
        Rename... skipEndRightObj

        selectObject: "TextGrid skipEndLeftObj", "TextGrid skipEndRightObj"
        Concatenate
        if beginning > 0 && skip_beginning <= 0
            Rename... 'filename$' part
        else
            Rename... 'filename$' trimmed
        endif

        removeObject: "TextGrid " + filename$


        if debug = 0
            removeObject: "TextGrid skipEndLeftObj", "TextGrid skipEndRightObj"
        endif


        select Sound 'filename$'
        View & Edit
        editor: "Sound " + filename$
        Move cursor to... 'skipEndLeftPoint'
        Move begin of selection by... 'skipEndRightPoint' - 'skipEndLeftPoint'
        Cut
        Close
        endeditor
        if beginning > 0 && skip_beginning <= 0
            Rename... 'filename$' part
        else
            Rename... 'filename$' trimmed
        endif
    endif


    if beginning > 0 && skip_beginning <= 0

        if skip_end > 0
            @refreshObjNames
            @refreshVars
        endif

        begCut = Get end point... 'tier' 'beginning'

        Extract part... 'begCut' 'textgridEndTime' "no"
        if end > 0 && skip_end <= 0
            Rename... 'filename$' part
        else
            Rename... 'filename$' trimmed
        endif

        removeObject: "TextGrid " + filename$

        select Sound 'filename$'
        Extract part... 'begCut' 'textgridEndTime' "rectangular" 1 "no"
        if end > 0 && skip_end <= 0
            Rename... 'filename$' part
        else
            Rename... 'filename$' trimmed
        endif

        removeObject: "Sound " + filename$
    endif


    if end > 0 && skip_end <= 0
        if beginning > 0
            @refreshObjNames
            @refreshVars
        endif

        cutHere = 'numIntervals' - 'end' + 1
        endCut = Get starting point... 'tier' 'cutHere'

        Extract part... 0 'endCut' "no"
        Rename... 'filename$' trimmed

        removeObject: "TextGrid " + filename$

        select Sound 'filename$'
        Extract part... 0 'endCut' "rectangular" 1 "no"
        Rename... 'filename$' trimmed

        removeObject: "Sound " + filename$
    endif

    if remove_original = 0
        select TextGrid 'filename$'_originalTmp
        Rename... 'filename$'
        select Sound 'filename$'_originalTmp
        Rename... 'filename$'
    endif
endif
