#pragma once

extern "C" void testCode_linux(
	unsigned long * const data, 
	const unsigned long long nItems1, 
	const unsigned long long nItems2, 
	const unsigned long long nItems3);

extern "C" void testCode_windows(
	unsigned long * const data,
	const unsigned long long nItems1,
	const unsigned long long nItems2,
	const unsigned long long nItems3);