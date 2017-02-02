# Reproducible Audio Research Seminar 2016

## Paper Selection

* [List of possible papers](https://github.com/faroit/reproducible-audio-research)

## Deliverables

To successfully pass the seminar we split the seminar sub tasks and several small deliverables:

### 1. Get familiar with reproducible research

 [Read this paper about reproducible research in Signal Processing](https://infoscience.epfl.ch/record/136640). This will give you an introduction why reproducibility is important. Also you will be introduced into what are papers with a high degree of reproducibility. When you reproduce your paper you will be asked to judge on the papers reproducibility:

##### Six Degrees of Reproducibility
 1. Cannot be reproduced.
 2. Cannot seem to be reproduced.
 3. Could be reproduced, requiring extreme effort.
 4. Can be reproduced, requiring considerable effort.
 5. Can be easily reproduced with at most 15 minutes of user effort, requiring some proprietary source packages.
 6. Can be easily reproduced with at most 15 min of user effort, requiring only standard, freely available tools


### 2. Reproduce the paper and submit documentation via [pull request](https://help.github.com/articles/about-pull-requests/)

* **Deadline for submitting a pull request**: 14.12.2016
* **Final Deadline (updates of PRs are allowed)**: 21.12.2016
* We will merge all pull requests on 21.12.2016. Late submissions are not possible.

After you get appointed to a paper, read the paper carefully and get back to the supervisors for questions about the technical content of the paper. When you are familiar with the topic, you can start with the actual reproducibility report. To make it easer for you and for us, we would encourage you to split this task into several subtask where each is (ideally) self-contained.

Each of these sub-tasks should therefore itself be submitted in reproducible manner. This means that your contributions should contain documentation and code how to easily reproduce the papers results in a short amount of time.

### 2.1. Document and set up computing environment

Regardless of the programming languages and operating systems you are going to use to reproduce the paper, it is important to document your machine setup and thus allow other people to recreate your environment.

E.g. if you use python:

* State the version of python that you have used
* State your package requirements (create [`requirements.txt`](https://pip.pypa.io/en/stable/user_guide/#requirements-files) or [`environment.yml`](http://conda.pydata.org/docs/using/envs.html#share-an-environment) if you use [Anaconda](https://anaconda.org)).

E.g. if you use Matlab, make sure that you document the [include paths](https://de.mathworks.com/help/matlab/matlab_env/what-is-the-matlab-search-path.html).

Your environment may change during development, e.g. when you install new packages. This is normal and should be reflected in `requirements.txt`.

### 2.2. Aggregate the dataset

In most cases the methods will be evaluated on publicly available data. These datasets are downloadable from the internet. Since only few methods actually deal with raw audio, this sub-task should make sure that the data is read an preprocessed in manner that allows the actually algorithm to easily process the data. The output of this sub-task could be a script that

* **automatically fetches** the datasets using tools like `wget` ,`cURL`
* **preprocesses** the data. This could include: file operations like renaming, unzipping.
* **parsing Metadata**
* **computes features**
* **writes out** the dataset in a format that allows for fast reading and writing (`hdf5`, `mat`, ...)

### 2.3. Process the dataset

After you have preprocessed the data we want to process the data by using the methods described in the paper.

The output of this sub-task could be a script that:

* **loads** the pre-processed data
* **applies the methods/algorithms** described the paper on the loaded dataset
* **writes out** the results so that they can easily evaluated in the next step. Be aware to write out relevant metadata as well as the processed audio data, depending on paper method.

### 2.4. Evaluate the processed data

This subtask is the most important one. The goal should be to reproduce the main results figure of the paper being reproduced. To archive this goal:

* **load the processed data and/or metadata**
* Compute the evaluation metrics as described in the paper
* Write out the aggregated metrics/scores
* Plot the results

### 3. Presentation

The presentations should consists of three parts:

1. Describe the paper and give a short outline of the research field, including the possible applications.
2. Describe the methods you have used to reproduce the paper.
3. Evaluate the degree of reproducibility.

## Submitting Seminar Deliverables

For the reproducible research seminar we are handling deliverables through [GitHub](https://github.com/) (which means it will be necessary that you all have an account) If you don't have experience with git/GitHub, don't worry, you can do everything from your browser; see below for a tutorial.
If you are comfortable with using git, please follow these steps to create a submission:

1. Create a fork of this repository by clicking on the "Fork" button at the top of this page.
2. In your fork, add content to the deliverables folder by copying the template from the template directory and rename it to match your paper and name. The folder should be named `(Your-last-name)-(last-name-of-first-author-of-paper-being-reproduced)`
3. Create a pull request to merge your fork. Make the title of the pull request to the subtask you want to propose.
4. We will review the pull request (be aware that we will only review deliverables that were pushed before the deadline; You can make update revisions of your deliverable before the deadline by updating your pull request.

Even if you have no experience with git or the command line you can upload your submissions through the github website (look for the upload button). If you have any issues, please don't hesitate to email us.

Some nonsense.

Some more.
