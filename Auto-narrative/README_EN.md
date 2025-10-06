# autoconversacion.sh

**Mistral Conversation Script**

This script allows interaction with the Mistral language model via `llama-cli` to generate empathetic and realistic conversations. It combines the creativity of artificial intelligence with a system for generating random sentences that include subjects, verbs, actions, complements, and emotions, producing more human-like and varied dialogues. Additionally, the script maintains a history of interactions and handles temporary files automatically, ensuring a clean and safe workflow.

## Functionality

The script creates random sentences from a combination of carefully selected linguistic elements to convey emotions and context. Each execution produces new sentences that are saved in a memory file (`MEMORIA`), allowing the model to reference the history and generate coherent and contextually enriched responses.  

Two interaction rounds are performed per execution: the first generates the initial sentence and obtains the model's response, while the second uses the conversation history to create continuity and depth in the dialogue.  

All temporary files generated during execution are automatically removed at the end, preventing data accumulation and keeping the environment clean (`TEMP_DIR`).

## Usage

Make the script executable with `chmod +x autoconversacion.sh`.  
Run the script using `./autoconversacion.sh` from the terminal.  

During execution, you will be asked to provide the necessary paths for proper operation: the model location (`MODELO_PATH`), the execution binary (`MAIN_BINARY`), the file where the conversation memory will be stored (`MEMORIA`), and the temporary directory (`TEMP_DIR`).  

After completion, you can review the generated conversation directly in the console and check the full history in the memory file. This allows you to maintain conversation continuity and reuse data for future executions.

## Requirements

The script is designed to run on macOS with Bash 5 or higher.  
You need to have the Mistral model in `.gguf` format and the `llama-cli` binary correctly compiled and functional.  
It is recommended to have sufficient CPU and memory resources to allow the model to process prompts efficiently, especially during extended sessions.

## Additional Considerations

This script is especially useful for text generation experiments, conversation simulations, language model testing, and interactive content creation.  
It is recommended to periodically review the memory file to evaluate coherence and adjust generation parameters in `llama-cli` as needed.  
The modular design allows expanding sentence generation functions, adding new subjects, verbs, or emotions, and customizing the interaction behavior without modifying the core logic.

**Eto Demerzel** (Gustavo Silva Da Costa)
https://etodemerzel.gumroad.com  
https://github.com/BiblioGalactic
