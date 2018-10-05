
#include <cstdio>
#include <vector>

#include "my_headers.h"

int main()
{
	std::vector<unsigned long> v;

	unsigned long long dim1 = 10;
	unsigned long long dim2 = 20;
	unsigned long long dim3 = 30;

	// allocate memory, but do not initialize it.
	unsigned long long size_v = dim1*dim2*dim3;
	v.resize(size_v);

	testCode(v.data(), dim1, dim2, dim3);

	for (int i = 0; i < size_v; ++i) {
		std::printf("%u,", v[i]);
	}

	printf("\nPress RETURN to finish");
	getchar();
	return 0;
};

