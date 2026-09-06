'From Cuis7.9 [latest update: #8156] on 6 September 2026 at 9:50:01 am'!

!MorphicCanvas class methodsFor: 'instance creation' stamp: 'jmv 6/Sep/2026, 12:49:19 pm (UTC)'!
onFormWithTranslucency: aForm
	"Use this message when you want to support target translucency.
   | icon canvas iconExtent |
    iconExtent := 50 @ 50.
    icon := Form extent: iconExtent depth: 32.
    canvas := VectorCanvas onFormWithTranslucency: icon.
    canvas fillColor: `Color orange alpha: 0.5` do: [
        canvas moveTo: 0@0;
            lineTo: iconExtent x @0;
            lineTo: 0 @ iconExtent y;
            lineTo: 0@0].
    icon
	"

	| answer |
	answer := self onFormWithSubPixelAntiAliasing: aForm.
	answer engine disableSubPixelSampling.
	^answer! !

