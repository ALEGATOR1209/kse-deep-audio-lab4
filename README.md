# Assignment 4

Yevhenii Zasko & Oleh Kovalyshyn

![](img/image.png)

## EDA and Metric Analysis

LJSpeech is a one-speaker dataset of 13,100 samples read from non-fiction books. Dataset's README contains basic statistics:

| Metric | Value |
| --- | --- |
| Total Clips | 13,100 |
| Total Words | 225,715 |
| Total Characters | 1,308,674 |
| Total Duration | 23:55:17 |
| Mean Clip Duration | 6.57 sec |
| Min Clip Duration | 1.11 sec |
| Max Clip Duration | 10.10 sec |
| Mean Words per Clip | 17.23 |
| Distinct Words | 13,821 |

Some words are abbreviated in the transcript:

| Abbreviation | Expansion |
| --- | --- |
| Mr. | Mister |
| Mrs. | Misess (*) |
| Dr. | Doctor |
| No. | Number |
| St. | Saint |
| Co. | Company |
| Jr. | Junior |
| Maj. | Major |
| Gen. | General |
| Drs. | Doctors |
| Rev. | Reverend |
| Lt. | Lieutenant |
| Hon. | Honorable |
| Sgt. | Sergeant |
| Capt. | Captain |
| Esq. | Esquire |
| Ltd. | Limited |
| Col. | Colonel |
| Ft. | Fort |

* there's no standard expansion of "Mrs."

Dataset's sample rate is 22050. Clip duration distribution:

![](img/clip_duration.png)

### Metrics

The proposed metrics are CER, UTMOS and SECS. All of them rely on another model that evaluates the output.

* **UTMOS** reflects speech naturalness and perception quality.
* **SECS** (Speaker Encoder Cosine Similarity) shows how much the original and generated voices are similar
* **CER** measures the difference between the original text and transcribed from the output.

A thing to note is that all these metrics rely on a good quality of the evaluating models. If Whisper makes an error during transcription, that could unfairly lower our model's score. At the same time, if the models recover the correct text even from low-quality outputs, it show model for better than it's actually worth.

An alternative metric to somewhat mitigate these limitations could be CER, but calculated not against the original, labeled text, but against the transcript of the input sample. The label-transcript CER then could also be used to detect potential problems with the data or Whisper.

## Validation

### Test/Train/Val Splits

Train and test splits were obtained by randomly splitting the dataset. 10% of the samples (1310) were included in the test fold. Then, validation fold was additionally carved out from train, with 10% of samples set out for the new split. Resultant statistics:

| Split | # Samples |
|-------|-----------|
| Train | 10 611    |
| Val   | 1 179     |
| Test  | 1 310     |

### Alternative Dataset

As an alternative dataset, synthbot's [pony-speech](https://huggingface.co/datasets/synthbot/pony-speech) dataset was used. It's a collection of labeled speech samples from My Little Pony TV Show. The dataset includes a total of 64.8K samples across 227 speakers.

![](img/mlp_speakers.png)

We decided to focus only on the top-3 speakers to reproduce a dataset, similar to LJSpeech. This way, we created 3 different datasets for samples from Twilight Sparkle, Rainbow Dash and Applejack. Only non-noised samples were included. All samples were re-sampled to 22050 Hz. Resulting statistics:

| Dataset          | # Samples |
|------------------|-----------|
| Twilight Sparkle | 4 549     |
| Applejack        | 3 031     |
| Rainbow Dash     | 2 243     |
| **Total**        | **9 823** |

Durations distributions were similar across the datasets:

![](img/mlp_clip_duration.png)

### LLM-generated Cases

For additional edge cases, we asked Claude to generate input texts and selected some of them. The generated texts include numbers, abbreviations, dates, heteronyms (past tense "read" vs present tense "read"), web urls, degenerate inputs (empty, emojis), etc.

## GPT TTS

We implemented GPT TTS system based on focalcodec and pre-trained GPT2 model and trained it on LJSpeech data. The resutls were unsatisfactory, with clear overfitting patter showing for train dataset.

To diagnose the issue we tried to measure "speaker reliance" (for multispeaker runs) and "text reliance" - the measure of how much does the loss change when we randomly permute either text tokens or randomly replace the speaker token.

### Attempt to solve overfitting issue

To fight the overfitting several approaches were used


Dataset increased by addition of my little pony and vctk dataasets
| Dataset | train | val | test | total |
|---------|------:|----:|-----:|------:|
| lj      | 10,611 | 1,179 | 1,310 | 13,100 |
| vctk    | 35,209 | 4,397 | 4,464 | 44,070 |
| pony    | 16,214 | 2,026 | 2,032 | 20,272 |
| **All** | **62,034** | **7,602** | **7,806** | **77,442** |

This dataset was used against the original gpt2tts and reduced gpt model with ~10M params

The original showed signes of overfitting aroung 4th epoch with val loss platoed
![alt text](img/gpt_default_10ep_large_ds.png)

The reduced version showed relativelly good performance, still platoed around 40-50 epoch with ~6.5 val loss. This model was without pretrained weights, showed better results in both text_reliance and spk_reliance then the original one.
![alt text](img/gpt_smaller_50ep_large_ds.png)
> the potential approach would be to reduce it even further, but even with 10m params ~65% is the gpt's wte(text token embeddings).

We also tried to do tokenizing by phonemes, the results below:

![](img/loss.png)

Given the big loss and poor quality of generated samples, we did not calculate the subsequent metrics like WER, SECS and so on. Empirically, the model learned to distinguish speaker voices on multi-speaker runs and generate sound that sounds like their voice. Still we couldn't get it to generate the actual audiable words.

## AI Use Disclosure
Claude Code was used to brainstorm ideas, generate plots and some scripts, validate approaches and debug code.

Our chats:
1. https://claude.ai/share/c8865b20-04a2-4afd-8e8b-86a987cdb03e
