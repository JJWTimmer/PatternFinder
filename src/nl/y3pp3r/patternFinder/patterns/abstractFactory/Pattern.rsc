module nl::y3pp3r::patternFinder::patterns::abstractFactory::Pattern

import lang::java::m3::TypeSymbol;

extend nl::y3pp3r::patternFinder::lib::Pattern;

data Pattern = abstractFactory(TypeSymbol interface, set[Factory] factories);

data Factory = factoryImpl(TypeSymbol class, set[TypeSymbol] products);