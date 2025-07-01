from pathlib import Path

import keras

from orcAI.architectures import (
    MaskedBinaryAccuracy,
    MaskedBinaryCrossentropy,
    build_model,
)
from orcAI.io import read_json

model_paths = {
    "1DC": Path("trained_models/orcai-v1-3750-1DC_1"),
    "LSTM": Path("trained_models/orcai-v1-3750-LSTM_1"),
}

for model_name, model_path in model_paths.items():
    orcai_parameter = read_json(model_path.joinpath("orcai_parameter.json"))
    model_parameter = orcai_parameter["model"]

    shape_path = model_path.joinpath("model_shape.json")
    dataset_shape = read_json(shape_path)

    model = build_model(tuple(dataset_shape["input_shape"]), orcai_parameter)

    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=model_parameter["learning_rate"]),
        loss=MaskedBinaryCrossentropy(),
        metrics=[MaskedBinaryAccuracy()],
    )

    print(f"Number of layers in {model_name} model: {len(model.layers)}")

    model_structure_plot_path = Path(
        f"analysis_scripts/output/{model_name}-model_structure.pdf"
    )
    keras.utils.plot_model(
        model,
        to_file=model_structure_plot_path,
        show_shapes=True,
        show_dtype=True,
        show_layer_names=False,
        rankdir="TB",
        expand_nested=True,
        dpi=200,
        show_layer_activations=True,
        show_trainable=True,
    )
