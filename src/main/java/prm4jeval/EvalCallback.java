package prm4jeval;

import java.util.Arrays;

import org.dacapo.harness.Callback;
import org.dacapo.harness.CommandLineArgs;
import org.dacapo.parser.Config;

public class EvalCallback extends Callback {

    private final EvaluationData evaluationData;
    private final SteadyStateEvaluation sse;

    private int iterationCount = 0;

    private long startTime;

    public EvalCallback(CommandLineArgs args) {
	super(args);
	evaluationData = new EvaluationData("evaluationData.ser");
	sse = evaluationData.getSteadyStateEvalation(System.getProperty("prm4jeval.benchmark"),
		System.getProperty("prm4jeval.parametricProperty"));
	System.out.println("EvalCallback loaded." + Arrays.toString(args.getArgs()));
    }

    @Override
    public void complete(String benchmark, boolean valid) {
	System.out.println("[DaCapo] Completed iteration nr.: " + iterationCount);
	super.complete(benchmark, valid);
    }

    @Override
    public void init(Config arg0) {
	System.out.println("[DaCapo] Initializing...");
	super.init(arg0);
    }

    @Override
    public void start(String benchmark) {
	startTime = System.currentTimeMillis();
	System.out.println("[DaCapo] Starting iteration " + ++iterationCount);
	super.start(benchmark);
    }

    @Override
    public void stop() {
	long elapsedTime = System.currentTimeMillis() - startTime;
	sse.getCurrentInvocation().addMeasurement(elapsedTime);
	System.out.println("[DaCapo] Stopping... time: " + elapsedTime);
	super.stop();
    }

    @Override
    public boolean runAgain() {
	evaluationData.storeEvaluationData();
	if (sse.getCurrentInvocation().isThresholdReached()) {
	    sse.closeCurrentInvocation();
	    evaluationData.storeEvaluationData();
	    System.out.println("[prm4jeval] Threshold reached after " + iterationCount + "iterations , exiting!");
	    System.exit(1);
	}
	return true;
    }

}
