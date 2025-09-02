import Foundation
import MLXLMCommon
import MLXLLM

struct ConcreteClipperLLM: ClipperLLM {
    var id: String
    var name: String
    var description: String
}

let models = LLMRegistry.llama3_8B_4bit

let modelList: [ConcreteClipperLLM] = [
    .init(
        id: "mlx-community/quantized-gemma-2b-it",
        name: "Gemma-2B Quantized",
        description: "A 2-billion-parameter model from the Gemma series, quantized for efficient inference."
    ),
    .init(
        id: "mlx-community/gemma-2-2b-it-4bit",
        name: "Gemma-2.2B-IT-4bit",
        description: " An Italian language model with 2.2 billion parameters, quantized to 4-bit for optimized performance."
    ),
    .init(
        id: "mlx-community/Llama-3.2-3B-Instruct-4bit",
        name: "LLaMA 3 2.3B 4bit",
        description: "A 2.3-billion-parameter model from LLaMA 3, quantized for enhanced performance."
    ),
    .init(
        id: "mlx-community/Mistral-Nemo-Instruct-2407-4bit",
        name: "Mistral-NeMo-4bit",
        description: "A variant of the Mistral model integrated with NVIDIA’s NeMo framework, quantized for optimized performance."
    ),
    .init(
        id: "mlx-community/OpenELM-270M-Instruct",
        name: "OpenELM-270M-4bit",
        description: "A 270-million-parameter model from the OpenELM project, quantized to 4-bit precision."
    ),
    .init(
        id: "mlx-community/Phi-3.5-MoE-instruct-4bit",
        name: "Phi-3.5 MoE",
        description: "A mixture of experts (MoE) model with 3.5 billion parameters, designed for specialized tasks."
    ),
    .init(
        id: "mlx-community/Phi-3.5-mini-instruct-4bit",
        name: "Phi-3.5-4bit",
        description: "A 3.5-billion-parameter model from the Phi series, quantized to 4-bit for efficient performance."
    ),
    .init(
        id: "mlx-community/phi-2-hf-4bit-mlx",
        name: "Phi-4bit",
        description: "A model from the Phi series, quantized to 4-bit precision for optimized inference."
    ),
    .init(
        id: "mlx-community/Qwen1.5-0.5B-Chat-4bit",
        name: "Qwen-2.0-5B-4bit",
        description: "A 5-billion-parameter model from the Qwen 2.0 series, quantized for efficient deployment."
    ),
    .init(
        id: "mlx-community/Qwen2.5-1.5B-Instruct-4bit",
        name: "Qwen-2.5-1.5B",
        description: "A 1.5-billion-parameter model in the Qwen 2.5 lineup, optimized for various applications."
    ),
    .init(
        id: "mlx-community/SmolLM-135M-Instruct-4bit",
        name: "SmolLM-135M-4bit",
        description: "A compact 135-million-parameter language model, quantized to 4-bit for lightweight applications."
    ),
]
