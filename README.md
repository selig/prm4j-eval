# prm4j-eval

Evaluation environment to measure and compare the performance of [prm4j][1] and [JavaMOP 3.0.0][2] (build 232) using the [DaCapo-9.12-bach][3] benchmark suite.

##Usage

Although this is a maven project, it is not necessary to `mvn compile` or `mvn install` it. Maven is used in the background for dependency resolution. Try to do the following:

* Test DaCapo by running `./dacapo avrora`, which should start the avrora benchmark after downloading all needed dependencies. (This may take a while to download up to 180 MB of dependencies).
* Run a monitoring aspect with
	* JavaMOP by executing `./javamop <aspectname> <benchmark>`, e.g. `./javamop SafeMapIterator avrora`
	* prm4j by executing `./prm4j <aspectname> <benchmark>`, e.g. `./prm4j SafeMapIterator avrora`
* Optional: Run a configured evaluation by executing `./eval`

You **don't** need to have [AspectJ][4] installed, the necessary AJC compiler is retrieved via maven as well.

---

Part of my thesis; currently in development (pre-alpha).


  [1]: https://github.com/parzonka/prm4j
  [2]: http://fsl.cs.uiuc.edu/index.php/Special:JavaMOP3
  [3]: http://dacapobench.org
  [4]: http://www.eclipse.org/aspectj