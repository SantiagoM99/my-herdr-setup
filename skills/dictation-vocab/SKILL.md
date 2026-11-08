---
name: dictation-vocab
description: Review the user's dictation vocabulary (herdr-dictate, Whisper) against their logged dictations, find terms Whisper mis-transcribes, prove each fix by re-transcribing the saved audio, and update dictate-words.txt after the user approves. Use when the user asks to review, tune or update their dictation vocabulary, or says dictation keeps getting a word wrong.
---

# dictation-vocab

`herdr-dictate` passes a comma-separated vocabulary to Whisper as its initial prompt, which biases spelling toward those terms. This skill keeps that list matched to how the user actually talks.

## Files

| Path | Holds |
|---|---|
| `~/.config/herdr-setup/dictate-words.txt` | The vocabulary, one line, comma-separated. Per-machine: never copy it into the repo |
| `~/.local/share/herdr-setup/dictations/log.tsv` | One line per dictation: `time<TAB>language<TAB>text` |
| `~/.local/share/herdr-setup/dictations/<time>.wav` | Audio of the last 50 dictations, named like the log's `time` |
| `~/.local/share/herdr-setup/*.bin` | Whisper and VAD models |

Transcribe a clip exactly as `herdr-dictate` does (read the command from `bin/herdr-dictate` if this drifts):

```bash
M=~/.local/share/herdr-setup
whisper-cli -m $M/ggml-large-v3-turbo-q5_0.bin --vad -vm $M/ggml-silero-v5.1.2.bin \
  -l auto -nt --prompt "<vocabulary>" -f <clip>.wav 2>/dev/null
```

## Steps

1. **Read the evidence.** Load the vocabulary and the log. Focus on lines whose language is `es`: the user mostly dictates in English, and the misses are English terms inside Spanish speech. Done when every log line has been read.
2. **List suspects.** A suspect is a token that reads as a mangled English term, product, library or project name (`finetunint`, `Chagipiti`), or a correct term the vocabulary lacks that recurs. Also list vocabulary terms that never appear in the log: candidates to drop. Ask the user what they said when a suspect is ambiguous; never guess a project name.
3. **Prove each change.** For every suspect that has audio, re-transcribe the clip with the current vocabulary and with the proposed one. A change is proven when the proposed run spells the term right and nothing else in the clip gets worse. Keep unproven suggestions separate and say they lack audio.
4. **Propose.** Show a table: term, add or drop, log lines as evidence, before and after transcripts. Keep the list under about 60 terms: Whisper reads only about 220 prompt tokens, and rare terms in a long list start appearing where the user never said them.
5. **Apply** only the changes the user approves, by rewriting `dictate-words.txt`. Done when the file holds exactly the approved list.

The log and audio are the user's private speech: read them locally and quote only the lines needed as evidence.
