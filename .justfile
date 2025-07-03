make-all:
    just make-plots make-tables make-stats make-pdf-tables

make-plots: extract-metrics
    Rscript analysis_scripts/training_history_plot.R
    Rscript analysis_scripts/hpsearch_plot.R
    uv run analysis_scripts/model_structure.py

make-tables: extract-metrics 
    Rscript analysis_scripts/confusion_table.R
    Rscript analysis_scripts/misclassification_table.R
    Rscript analysis_scripts/hps_trials_table.R

make-stats: extract-metrics
    Rscript analysis_scripts/training_time.R
    Rscript analysis_scripts/model_stats.R

make-pdf-tables: make-tables
    pdflatex -output-directory analysis_scripts/output analysis_scripts/table4_confusion.tex
    rm analysis_scripts/output/table4_confusion.aux analysis_scripts/output/table4_confusion.log
    
    pdflatex -output-directory analysis_scripts/output analysis_scripts/table5_misclassification_combined.tex
    rm analysis_scripts/output/table5_misclassification_combined.aux analysis_scripts/output/table5_misclassification_combined.log
    
    pdflatex -output-directory analysis_scripts/output analysis_scripts/table5_misclassification_TP.tex
    rm  analysis_scripts/output/table5_misclassification_TP.aux analysis_scripts/output/table5_misclassification_TP.log
    
    pdflatex -output-directory analysis_scripts/output analysis_scripts/table6_misclassification_PT.tex
    rm analysis_scripts/output/table6_misclassification_PT.aux analysis_scripts/output/table6_misclassification_PT.log
    
    pdflatex -output-directory analysis_scripts/output analysis_scripts/tableSI1_hps_trials.tex
    rm analysis_scripts/output/tableSI1_hps_trials.aux analysis_scripts/output/tableSI1_hps_trials.log

extract-metrics:
    echo "Extracting metrics..."
    Rscript analysis_scripts/tidy_model_metrics.R
    