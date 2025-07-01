run-all:
    Rscript analysis_scripts/tidy_model_metrics.R
    Rscript analysis_scripts/training_history_plot.R
    Rscript analysis_scripts/training_time.R
    Rscript analysis_scripts/model_stats.R
    Rscript analysis_scripts/confusion_table.R
    Rscript analysis_scripts/misclassification_table.R
    Rscript analysis_scripts/hpsearch_plot.R
    uv run analysis_scripts/model_structure.py

