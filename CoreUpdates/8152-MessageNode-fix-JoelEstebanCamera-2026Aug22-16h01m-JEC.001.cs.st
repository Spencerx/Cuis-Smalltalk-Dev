'From Cuis7.9 [latest update: #8145] on 22 August 2026 at 4:51:07 pm'!

!MessageNode methodsFor: 'testing' stamp: 'JEC 22/Aug/2026, 7:15:54 pm (UTC)'!
isReceiverVariableNotLiteral

	^ self receiver isVariableNode 
		and: [ self receiver isLiteralNode not
		and: [ self receiver isLiteralVariableNode not ] ]! !

