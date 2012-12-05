package prm4jeval;
import org.dacapo.harness.Callback;
import org.dacapo.harness.CommandLineArgs;
import org.dacapo.parser.Config;

public class EvalCallback extends Callback {

    private int iterationCount = 0;
    private final int maxIterations = 5;

    public EvalCallback(CommandLineArgs args) {
	super(args);
	System.out.println("EvalCallback loaded.");
    }

    @Override
    public void complete(String benchmark, boolean valid) {
	System.out.println("[DaCapo] Completed iteration.");
	super.complete(benchmark, valid);
    }

    @Override
    public void init(Config arg0) {
	System.out.println("[DaCapo] Initializing...");
	super.init(arg0);
    }

    @Override
    public void start(String benchmark) {
	System.out.println("[DaCapo] Starting iteration " + ++iterationCount);
	super.start(benchmark);
    }

    @Override
    public void stop() {
	System.out.println("[DaCapo] Stopping...");
	super.stop();
    }

    @Override
    public boolean runAgain() {
	final int iterationsLeft = maxIterations - iterationCount;
	System.out.println("[DaCapo] " + (maxIterations - iterationCount) + " iteration to go");
	return iterationsLeft > 0;
    }

}
