'From Cuis7.9 [latest update: #8146] on 23 August 2026 at 7:34:39 pm'!

!NodesInRangeFinder methodsFor: 'evaluating' stamp: 'JEC 23/Aug/2026, 9:56:36 pm (UTC)'!
value
	
	| nodeAtLastPositionFound |

	"Because some nodes have many ranges, like the literal nodes, we count the time we pass by a node that is equivalent
	to the index in the source ranges collection. sourceRangeIndexByNode is used to count per node - Hernan"
	sourceMethodNode := sourceMethod notOptimizedMethodNode.
	sourceCode := sourceMethod sourceCode.
	statements := OrderedCollection new.
	sourceRangeIndexByNode := IdentityBag new.
	firstNodeFound := false.

	sourceMethodNode nodesDo: [ :aNode | | nodeRange |
		sourceRangeIndexByNode add: aNode.
		nodeRange := self completeSourceRangeOf: aNode.
		nodeAtLastPositionFound := self ifInsideRangeAddToStatements: aNode locatedAt: nodeRange.
		nodeAtLastPositionFound ifTrue: [ ^statements ]].
			
	self signalNodesNotFound
	! !

