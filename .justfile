make-all:
    just make-plots make-tables make-stats make-pdf-tables

make-plots: extract-metrics
    Rscript analysis_scripts/training_history_plot.R
    Rscript analysis_scripts/hpsearch_plot.R
    uv run analysis_scripts/model_structure.py

make-tables: extract-metrics 
    Rscript analysis_scripts/confusion_table.R
    Rscript analysis_scripts/misclassification_table.R

make-stats: extract-metrics
    Rscript analysis_scripts/training_time.R
    Rscript analysis_scripts/model_stats.R

make-pdf-tables: make-tables
    pdflatex -output-directory analysis_scripts/output analysis_scripts/table4_confusion.tex
    rm analysis_scripts/output/table4_confusion.aux analysis_scripts/output/table4_confusion.log
    pdflatex -output-directory analysis_scripts/output analysis_scripts/table5_misclassification.tex
    rm analysis_scripts/output/table5_misclassification.aux analysis_scripts/output/table5_misclassification.log

extract-metrics:
    echo "Extracting metrics..."
    Rscript analysis_scripts/tidy_model_metrics.R
    