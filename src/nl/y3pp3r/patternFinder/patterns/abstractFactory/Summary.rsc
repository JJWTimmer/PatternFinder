module nl::y3pp3r::patternFinder::patterns::abstractFactory::Summary

import IO;
import List;
import Node;

import lang::java::m3::TypeSymbol;

import nl::y3pp3r::patternFinder::patterns::abstractFactory::Pattern;

public str summarize(abstractFactory(TypeSymbol interface, set[Factory] factories)) {
	return "Abstract factory for <interface>
		   '  <for(factory <- factories) { >Concrete factory: <factory.class>
		   '      factory method:  
		   '	    <for(product <- factory.products) {><product><}>
		   '  <}>";
}