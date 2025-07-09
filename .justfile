make-all:
    just make-stats make-plots make-tables make-stats make-pdf-tables

make-stats: extract-metrics
    Rscript analysis_scripts/training_time.R
    Rscript analysis_scripts/model_stats.R

make-plots: extract-metrics
    Rscript analysis_scripts/training_history_plot.R
    Rscript analysis_scripts/hpsearch_plot.R
    uv run analysis_scripts/model_structure.py

make-tables: extract-metrics 
    Rscript analysis_scripts/snippet_durations_table.R
    Rscript analysis_scripts/confusion_table.R
    Rscript analysis_scripts/misclassification_table.R
    Rscript analysis_scripts/hps_trials_table.R

make-pdf-tables: make-tables
    just render-table table3_filtered_snippets_duration
    just render-table table4_confusion
    just render-table table5_misclassification_combined
    just render-table table5_misclassification_TP
    just render-table table6_misclassification_PT
    just render-table tableSI1_hps_trials
    just render-table all_ms_tables

render-table basename:
    pdflatex -output-directory analysis_scripts/output/tables analysis_scripts/tex_intermediates/{{basename}}.tex
    rm analysis_scripts/output/tables/{{basename}}.aux analysis_scripts/output/tables/{{basename}}.log

extract-metrics:
    echo "Extracting metrics..."
    Rscript analysis_scripts/tidy_model_metrics.R
    