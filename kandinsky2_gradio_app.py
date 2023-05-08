#!/usr/local/bin/python3
import gradio as gr
from kandinsky2 import get_kandinsky2

def generate_image(prompt):
    model = get_kandinsky2('cuda', task_type='text2img', model_version='2.1', use_flash_attention=False)
    images = model.generate_text2img(
        prompt,
        num_steps=100,
        batch_size=1,
        guidance_scale=4,
        h=768, w=768,
        sampler='p_sampler',
        prior_cf_scale=4,
        prior_steps="5"
    )
    return images[0]

iface = gr.Interface(
    fn=generate_image,
    inputs=gr.inputs.Textbox(lines=2, label="Enter a description for the image:"),
    outputs=gr.outputs.Image(type="pil", label="Generated Image"),
    title="Kandinsky2 Text-to-Image Generator",
    description="Generate images from textual descriptions using the Kandinsky2 model.",
    examples=[["red cat, 4k photo"], ["sunset by the beach"], ["colorful city skyline"]]
)

iface.launch(share=True, server_name='0.0.0.0')
