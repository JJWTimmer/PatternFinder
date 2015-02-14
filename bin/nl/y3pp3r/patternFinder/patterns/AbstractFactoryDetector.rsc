module nl::y3pp3r::patternFinder::patterns::AbstractFactoryDetector

import lang::java::jdt::m3::Core;
import lang::java::m3::TypeSymbol;

import util::ValueUI;
import Relation;
import Set;

import nl::y3pp3r::patternFinder::patterns::abstractFactory::Pattern;

// loose = concrete classes can be abstract factories / return types too
public list[Pattern] detect(M3 project, bool loose = false) {
	
	// set of all methods returning something abstract
	abstractContainerMethods = getAbstractContainerMethods(project, loose);
	
	// to lookup the classes that contain the methods, reverse the containment relation	
	reverseContainment = invert(project@containment);
	
	// get all the containers ([abstract] classes or interfaces) that contain the methods returning something abstract
	abstractContainers = { *reverseContainment[m] | m <- abstractContainerMethods };
	
	set[loc] abstractFactoryCandidates;
	
	// if not loose mode, filter out concrete classes as abstract factories
	if (loose) {
		abstractFactoryCandidates = abstractContainers;		
	} else {
		abstractFactoryCandidates = {c | c <- abstractContainers, m <-project@modifiers[c], abstract() := m || isInterface(c)};
	}
	
	// split the candidates again in interfaces and abstract classes
	ifs = {c | c <- abstractFactoryCandidates, isInterface(c)};
	acs = {c | c <- abstractFactoryCandidates, isClass(c)};
	
	// maps from class/interface to collection of methods returning something abstract
	ifAbstractFactoryCandidatesMap = (i : ms | i <- ifs, ms := {m | m <- project@containment[i], m in abstractContainerMethods});
	acAbstractFactoryCandidatesMap = (c : ms | c <- acs, ms := {m | m <- project@containment[c], m in abstractContainerMethods});
	
	// sets of candidates for concrete factories
	abstractClassConcreteFactoryCandidates = { class | ac <- acAbstractFactoryCandidatesMap, <class, _> <- rangeR(project@extends   , {ac}) };
	interfaceConcreteFactoryCandidates     = { class |  i <- ifAbstractFactoryCandidatesMap, <class, _> <- rangeR(project@implements, {i} ) };
	
	// set of concrete factories
	map[loc, set[TypeSymbol]] factories = ();
	
	// map from concrete factories (extending class or implementing interface) to their methods returning something abstract
	acConcreteFactoryCandidatesMap = (c : ms | c <- abstractClassConcreteFactoryCandidates, ms := {m | m <- project@containment[c], m in abstractContainerMethods});
	ifConcreteFactoryCandidatesMap = (c : ms | c <- interfaceConcreteFactoryCandidates    , ms := {m | m <- project@containment[c], m in abstractContainerMethods});
	
	// for every concrete class extending an abstract class that is suspected of being an abstract factory
	for (candidate <- abstractClassConcreteFactoryCandidates){
		// get the methods that return something abstract from the candidate
		ms = acConcreteFactoryCandidatesMap[candidate];
		factories = getConcreteFactories(project, factories, candidate, abstractContainerMethods, ms);
	}
	
	// for every concrete class implementing an interface that is suspected of being an abstract factory
	for (candidate <- ifConcreteFactoryCandidatesMap){
		// get the methods that return something abstract from the candidate
		ms = ifConcreteFactoryCandidatesMap[candidate];
		factories = getConcreteFactories(project, factories, candidate, abstractContainerMethods, ms);
	}
	
	// data structure to generete resulting patterns
	map[loc abstractFactory, set[Factory] concreteFactories] abstractFactories = ();
	
	for (factory <- factories) {
		// set of the abstract factories, implemented or extended by concrete factories, filtering out non-factories
		abstractFactorySet = { af | af <- abstractFactoryCandidates, af in project@implements[factory] || af in project@extends[factory]};
		if (!isEmpty(abstractFactorySet)) {
			set[Factory] emtpy = {};
			for (af <- abstractFactorySet) { 
				abstractFactories[af] ? emtpy += {factoryImpl(getOneFrom(project@types[factory]), factories[factory])};
			}
		}
		
	}

	// for every abstract factory there is a set of concrete factories, with their factory methods
	return [abstractFactory(getOneFrom(project@types[factory]), abstractFactories[factory]) | factory <- abstractFactories];
}

//get all methods that have something abstract as the return type
private set[loc] getAbstractContainerMethods(M3 project, false) = 
	{
		t.name | t <- project@types,
		isMethod(t.name),
		t.typ has returnType,
		\interface(_, _) := t.typ.returnType
	}
	+
	{ 
		t.name | t <- project@types,
		isMethod(t.name),
		t.typ has returnType,
		\class(d, _) := t.typ.returnType,
		m <- project@modifiers[d],
		abstract() := m
	};
	

//get all methods that have a non void non primitive return type
private set[loc] getAbstractContainerMethods(M3 project, true) = 
	{
		t.name | t <- project@types,
		isMethod(t.name),
		t.typ has returnType,
		\interface(_, _) := t.typ.returnType
	}
	+
	{ 
		t.name | t <- project@types,
		isMethod(t.name),
		t.typ has returnType,
		\class(_, _) := t.typ.returnType
	};
	
private map[loc, set[TypeSymbol]] getConcreteFactories(M3 project, map[loc, set[TypeSymbol]] factories, loc candidate, set[loc] abstractContainerMethods, set[loc] ms) {
	set[TypeSymbol] emptyTypes = {};
	
	for (method <- ms) {
		// check for every method if it overrides a method from the abstract class
		factoryMethods = {overriddenMethod | overriddenMethod <- project@methodOverrides[method], overriddenMethod in abstractContainerMethods};
		// if it does, the candidate is a concrete factory
		if (!isEmpty(factoryMethods)) {
			factories[candidate] ? emptyTypes += {t | m <- factoryMethods, ts := project@types[m], {t} := ts };
		}
	}
	return factories;
}