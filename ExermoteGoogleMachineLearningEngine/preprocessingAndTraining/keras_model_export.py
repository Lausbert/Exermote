import keras.backend as K
from glob import glob
from keras.models import load_model, Sequential
from tensorflow.python.saved_model import builder as saved_model_builder
from tensorflow.python.saved_model import tag_constants, signature_constants
from tensorflow.python.saved_model.signature_def_utils_impl import predict_signature_def


#disable learning layers (as far as I understood)
K.set_learning_phase(0)

#load current best model
model_path = glob('*.h5')[0]
model = load_model(model_path)
config = model.get_config()
weights = model.get_weights()
new_Model = Sequential.from_config(config)
new_Model.set_weights(weights)

#export current best model
export_path = './Export'
builder = saved_model_builder.SavedModelBuilder(export_path)

signature = predict_signature_def(inputs={'accelerations': new_Model.input},
                                  outputs={'scores': new_Model.output})

with K.get_session() as sess:
    builder.add_meta_graph_and_variables(sess=sess,
                                         tags=[tag_constants.SERVING],
                                         signature_def_map={signature_constants.DEFAULT_SERVING_SIGNATURE_DEF_KEY: signature})
    builder.save()

