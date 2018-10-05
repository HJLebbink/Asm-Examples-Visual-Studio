
public class JniTest1 {
	
	static {
		final String archModel = System.getProperty("sun.arch.data.model");
		if (archModel.equals("32")) {
			System.loadLibrary("ExampleAppJni1_32");
		} else if (archModel.equals("64")) {
			System.loadLibrary("ExampleAppJni1_64");
		} else {
			System.out.println("SEVERE, unsupported arch model, found " + archModel);
		}
	}

	public native static long testCode(int[] data, long dim1, long dim2, long dim3);

	public static void main(String[] args) {
		
		long dim1 = 10;
		long dim2 = 20;
		long dim3 = 30;
		long size_v = dim1*dim2*dim3;

		// allocate memory
		int[] v = new int[(int)size_v];

		System.out.println("this is the moment to attach a debugger to this thread");
		pressAnyKeyToContinue();
		long r = testCode(v, dim1, dim2, dim3);

		for (int i = 0; i < size_v; ++i) {
			System.out.print(v[i]+",");
		}
	}

	private static void pressAnyKeyToContinue() {
		System.out.println("Press any key to continue...");
		try {
			System.in.read();
		}
		catch(Exception e){}
	}
}
