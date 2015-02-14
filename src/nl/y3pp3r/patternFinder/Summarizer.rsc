module nl::y3pp3r::patternFinder::Summarizer

import IO;
import List;
import Node;

import nl::y3pp3r::patternFinder::lib::Pattern;
import nl::y3pp3r::patternFinder::lib::Summary;

import nl::y3pp3r::patternFinder::patterns::abstractFactory::Summary;

public void printSummary(list[Pattern] patterns) {
	print("Found <size(patterns)> design patterns.
		  '
		  '<for(pattern <- patterns) {> 
		  '<summarize(pattern)>
		  '<}>
		  '
		  '
		  '");
}