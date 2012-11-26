# prm4j-eval

Evaluation environment to measure and compare the performance of [prm4j][1] and [JavaMOP 3.0.0][2] (build 232) using the [DaCapo-9.12-bach][3] benchmark suite.

##Usage

To run an an monitoring aspect with JavaMOP, run `./javamop <aspectname> <benchmark>`, e.g. `./javamop SafeMapIterator avrora`

##Prerequisites

 `dacapo-9.12-bach.jar` has to exist somewhere on your disk. If not, you can download it [here][4] (ca. 167 MB). 
  Let prm4j-eval find it by executing `export DACAPO=path/to/dacapo-9.12-bach.jar` before usage.

  You **don't** need to have [AspectJ][5] installed, the necessary dependencies are retrieved via Maven.

  (The only dependency included in the lib is the 'javamoprt.jar' because no public maven repository seems to exist containing it.)

---

Part of my thesis; currently in development (pre-alpha).


  [1]: http://dacapobench.org
  [2]: http://fsl.cs.uiuc.edu/index.php/Special:JavaMOP3
  [3]: http://dacapobench.org
  [4]: http://sourceforge.net/projects/dacapobench/files/9.12-bach/dacapo-9.12-bach.jar/download
  [5]: http://www.eclipse.org/aspectj