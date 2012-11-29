import org.dacapo.harness.Callback;
import org.dacapo.harness.CommandLineArgs;

public class EvalCallback extends Callback {

    private int iterationCount = 1;

    public EvalCallback(CommandLineArgs args) {
	super(args);
	System.out.println("EvalCallback loaded.");
    }

    @Override
    public boolean runAgain() {
	// lets do 2 iterations
	System.out.println("Iteration " + iterationCount + " passed.");
	return iterationCount++ <= 2;
    }

}
