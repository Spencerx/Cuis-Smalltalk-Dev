'From Cuis7.9 [latest update: #8148] on 26 August 2026 at 1:00:01 pm'!

!PluggableButtonMorph methodsFor: 'drawing' stamp: 'jmv 26/Aug/2026, 3:59:17 pm (UTC)'!
drawRoundLookOn: aCanvas
	| r colorForButton rect |
	colorForButton := self isPressed
		ifFalse: [
			self mouseIsOver
				ifTrue: [	 mouseOverColor ifNil: [
						Color h: color hue s: color saturation * 1.2 v: color brightness * 0.92 alpha: color alpha ]]
				ifFalse: [ color ]]
		ifTrue: [ mouseOverColor ifNil: [ color adjustSaturation: 0.1 brightness: -0.15 ]].

	r := Theme current roundedButtonRadius.
	rect := self roundButtonRect.
	r := r min: (rect width min: rect height) * 0.5.
	aCanvas roundRect: rect color: (self enableColorWith: colorForButton) radius: r.

	Theme current embossedButtonLabels
		ifTrue: [ self drawEmbossedLabelOn: aCanvas ]
		ifFalse: [ self drawRegularLabelOn: aCanvas ].! !

