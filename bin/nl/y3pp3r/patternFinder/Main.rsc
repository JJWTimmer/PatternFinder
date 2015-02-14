module nl::y3pp3r::patternFinder::Main

import lang::java::jdt::m3::Core;
import util::ValueUI;
import IO;
import List;
import lang::xml::DOM;

import nl::y3pp3r::patternFinder::patterns::AbstractFactoryDetector;
import nl::y3pp3r::patternFinder::patterns::abstractFactory::Pattern;
import nl::y3pp3r::patternFinder::patterns::abstractFactory::DPBXS;

import nl::y3pp3r::patternFinder::Summarizer;

public list[Pattern] run(loc project, bool loose=false) {
	println("Start analysis, loose = <loose>");
	proj = createM3FromEclipseProject(project);
	
	println("Starting detection");
	patterns = detect(proj, loose=loose);
	
	text(patterns);
	
	printSummary(patterns);
	
	writeFile(|project://PatternFinder/xml/test1.xml|, xmlPretty(toXml(patterns[0])));
	
	return patterns;
}

public void runPDB() {
	run(|project://org.eclipse.imp.pdb.values|);
}

public void runPDBLoose() {
	run(|project://org.eclipse.imp.pdb.values|, loose=true);
}

public void runHotDraw() {
	run(|project://JHotDraw|);
}

public void runHotDrawLoose() {
	run(|project://JHotDraw|, loose=true);
}

public void runPMD() {
	run(|project://PMD|);
}

public void runPMDLoose() {
	run(|project://PMD|, loose=true);
}