# prm4j-eval

Evaluation environment to measure and compare the performance of [prm4j][1] and [JavaMOP 3.0.0][2] (build 232) using the [DaCapo-9.12-bach][3] benchmark suite.

##Usage

Although this is a maven project, it is not necessary to `mvn compile` or `mvn install` it. Maven is used in the background for dependency resolution. Just follow this instructions to get it running:

* `dacapo-9.12-bach.jar` has to exist locally and the location has to be known to prm4j-eval.
	* If it does not exist, download it [here][4] (ca. 167 MB)
	* Add `export DACAPO=path/to/dacapo-9.12-bach.jar` to your profile or execute it in the local shell
	* Test DaCapo by running `./dacapo avrora`, which should start the benchmark instantly
* Run a monitoring aspect with
	* JavaMOP by executing `./javamop <aspectname> <benchmark>`, e.g. `./javamop SafeMapIterator avrora`
	* prm4j by executing `./prm4j <aspectname> <benchmark>`, e.g. `./prm4j SafeMapIterator avrora`
* Optional: Run a configured evaluation by executing `./eval`
 `

You **don't** need to have [AspectJ][5] installed, the necessary dependencies are retrieved via maven.

The only system dependency included in the lib is the 'javamoprt.jar' because no public maven repository seems to exist containing it.

---

Part of my thesis; currently in development (pre-alpha).


  [1]: http://dacapobench.org
  [2]: http://fsl.cs.uiuc.edu/index.php/Special:JavaMOP3
  [3]: http://dacapobench.org
  [4]: http://sourceforge.net/projects/dacapobench/files/9.12-bach/dacapo-9.12-bach.jar/download
  [5]: http://www.eclipse.org/aspectj