
# Report Title

## Report Instructions

Your report should

 - be brief but complete
 - be written in a simple text language like Markdown
 - contain all installation and evaluation commands
   - complex command sequences should be automated
   - aim for using at most 8 different commands, including download
   - command sequences should be highlighted as such

Your code must

 - install easily and cleanly
 - run without errors
 - not require knowledge of any parameters. If you use parameters, use scripts or give exact values in the report.

Your code should

 - not require modifications of the used tool


## Additional Tips

Familiarize yourself with how to download and extract data automatically.

Familiarize yourself with how to install software for your development environment. Most supply a method of reliably and automatically re-creating the environment (e.g `pip install -r requirements.txt`).

To test easy installation try deleting the environment and running the entire report/script from time to time.


## Example


> # Report Title
>
> This is an example report for the evaluation of a paper.
>
> ## Installation
>
> ### Installation
>
> To install the toolkit published with the paper, run
>
>     git clone git@github.com/some/paper.git
>     cd paper/
>     pip install -r requirements.txt
>
> ### Download Dataset and preprocess data
>  
>   ./download.sh
>   python preprocess.py ../dataset/* data.hdf5
>
> ### Process results
>
>   python process.py data.hdf5 output
>
> ### Evaluation
>
>   python evaluate.py output output.png
>
>
> The resulting figure `output.png` can be seen on page two of the paper.
>
>
> ## Evaluation
>
> During the evaluation of the paper *Title* I came across the following issues:
>
> Lorem ipsum dolor sit amet.
