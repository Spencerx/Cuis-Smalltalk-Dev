'From Cuis7.9 [latest update: #8150] on 2 September 2026 at 2:14:18 pm'!

!StringRequestMorph methodsFor: 'initialization' stamp: 'jmv 2/Sep/2026, 5:11:34 pm (UTC)'!
addTextPane
	"Add a text pane and two buttons."
	
	| controlsContainer e |
	textMorph := (TextModelMorph
		textProvider: self
		textGetter: #response
		textSetter: #response:
		selectionGetter: #selectionInterval) emptyTextDisplayMessage: 'Enter response'.
	self
		valueOfProperty: #emptyTextDisplayMessage
		ifPresentDo: [ :msg |
			textMorph emptyTextDisplayMessage: msg ].
	textMorph
		hasUnacceptedEdits: true; "Allow accepting initial contents"
		acceptOnCR: true;
		escAction: [ self cancel ].
	e := FontFamily defaultLineSpacing asPoint print.
	(controlsContainer := LinearLayoutMorph newRow color: Color transparent)
		addMorphUseAll: textMorph;
		addMorph: 
			((PluggableButtonMorph model: self action: #ok)
				setBalloonText: 'OK' bold, ' (accept input)';
				icon: Theme current acceptIcon;
				morphExtent: e);
		addMorph:
			((PluggableButtonMorph model: self action: #cancel)
				setBalloonText: 'Cancel' bold, '  (discard input)';
				icon: Theme current cancelIcon;
				morphExtent: e).
	self addMorphUseAll: controlsContainer! !

