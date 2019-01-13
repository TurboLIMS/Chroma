## Chroma::Reader Gem

Chroma is a PDF and CSV parser for chromatography batch reports, with some
input parameters that allows flexibility in the analysis of the input.

Header discovery, row discovery, column exclusion, column reordering.

```
>> REPORT START 2019-01-11 16:41
Sample_23 781.674 507.096 662.184 678.83 109.636 581.873 500.424 651.328 596.718 64.142 122.673
Sample_35 683.892 317.118 359.568 13.52 735.353 218.804 381.964 625.032 781.882 685.874 856.873
Sample_37 341.68 780.786 679.52 843.436 613.123 729.566 94.02 454.303 584.151 152.453 230.487
<< REPORT END 2019-01-11 16:43
```

### Input options for the Chroma::Reader constructor

* input: File or file_path of the report to read
* header_regex: RE to identify the header row
* header_column_regex: RE to identify the header column separator (overwrites column_regex)
* header_skip_column: array of indexes of columns to ignore (overwrites skip_column)
* header_append: array of elements to append to the header
* header_prepend: array of elements to prepend to the header
* header_sort: array of strings to sepcify the order of columns
* row_regex: RE to indentify data rows
* column_regex: RE to identify the column separator
* skip_column: array of indexes of columns to ignore
* should_scrub_re: RE to remove a ancor from data rows
* reject_sample_regex: RE to reject sample-id
