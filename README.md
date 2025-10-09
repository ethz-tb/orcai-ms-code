# Additional code used for orcAI manuscript

orcAI has been published in the Journal Marine Mammal Science as:

Bonhoeffer, S. et al. 2025. “orcAI: A Machine Learning Tool to Detect and Classify Acoustic Signals of Killer Whales in Audio Recordings.” Marine Mammal Science e70083. https://doi.org/10.1111/mms.70083.

```bibtex
@article{https://doi.org/10.1111/mms.70083,
  author = {Bonhoeffer, Sebastian and Selbmann, Anna and Angst, Daniel C. and Ochsner, Nicolas and Miller, Patrick J. O. and Samarra, Filipa I. P. and Baumgartner, Chérine D.},
  title = {orcAI: A Machine Learning Tool to Detect and Classify Acoustic Signals of Killer Whales in Audio Recordings},
  journal = {Marine Mammal Science},
  volume = {n/a},
  number = {n/a},
  pages = {e70083},
  keywords = {bioacoustics, cetaceans, deep learning},
  doi = {https://doi.org/10.1111/mms.70083},
  url = {https://onlinelibrary.wiley.com/doi/abs/10.1111/mms.70083},
  eprint = {https://onlinelibrary.wiley.com/doi/pdf/10.1111/mms.70083},
  note = {e70083 9425791},
  abstract = {ABSTRACT Acoustic monitoring is an essential tool for investigating animal communication and behavior when visual contact is limited, but the scalability of bioacoustic projects is often limited by time-intensive manual auditing of focal signals. To address this bottleneck, we introduce orcAI—a novel deep learning framework for the automated detection and classification of a broad acoustic repertoire of killer whales (Orcinus orca), including vocalizations (e.g., pulsed calls, whistles) and incidental sounds (e.g., breathing, tail slaps). orcAI combines a ResNet-based Convolutional Neural Network (ResNet-CNN) with Long Short-Term Memory (LSTM) layers to capture both spatial features and temporal context, enabling the model to classify signals and to accurately determine their temporal boundaries in spectrograms. Trained on a comprehensive dataset from herring-feeding killer whales off Iceland, the framework was designed to be adaptable to other populations upon training with equivalent data. Our final model achieves up to 98.2\% accuracy on test data and is delivered as an open-source tool with an easy-to-use command-line interface. By providing a ready-to-use model that processes raw audio and outputs annotations, orcAI serves as a useful tool for advancing the study of killer whale vocal behavior and, more broadly, for understanding marine mammal communication and ecology.}
}

## Contents

- [orcai_v1.md]
  - contains the annotated pipeline used to generate the main model ([orcai_v1.md])
- [input_parameter/]
  - contains json files with input parameter for the various [orcAI] functions used in [orcai_v1.md].
- [model_training_scripts/]
  - contains the scripts used run the various [orcAI] functions used in [orcai_v1.md] on the ETHZ euler cluster
- [hyperparameter_search/]
  - contains hyperparameter search results summary.
- [trained_models/]
  - contains all trained models, training logs and test results (e.g. [/trained_models/orcai-v1_1/test])
- [analysis_scripts/]
  - contains various R and python scripts used for analysis and plotting of results.

[input_parameter/]:input_parameter
[orcAI]:https://github.com/ethz-tb/orcAI
[orcai_v1.md]:orcai-v1.md
[model_training_scripts/]:model_training_scripts
[trained_models/]:trained_models
[hyperparameter_search/]:hyperparameter_search
[/trained_models/orcai-v1_1/test]:trained_models/orcai-v1_1/test
[analysis_scripts/]:analysis_scripts
