<script lang="ts">
    import { onMount } from 'svelte';
    import { Receive } from '@enums/events';
    import { ReceiveEvent, SendEvent } from '@utils/eventsHandlers';
    import HexSVG from '@components/hex.svg';
    
    interface Buttons {
        label: string;
        id?: string | number;
        reqRep: number;
    }
    interface Dialogue {
        job: string;
        name: string;
        text: string;
        buttons: Buttons[];
    }

    interface ShowDialogueData {
        rep: number;
        dialog: Dialogue;
        ped_id: string;
    }

    interface UpdateDialogueData {
        type: string;
        value: string | Buttons[] | number;
    }

    let currentDialogue: Dialogue = {
        job: '',
        name: '',
        text: '',
        buttons: [],
    };

    let rep: number = 0;
    let ped_id: string = '';

    let displayedText = '';
    let index = 0;
    let finish = false;

    function typeWriterEffect() {
        if (index < currentDialogue.text.length) {
            displayedText += currentDialogue.text.charAt(index);
            index++;
            setTimeout(typeWriterEffect, 25);
        } else {
            finish = true;
        }
    }

    function refreshText() {
        index = 0;
        displayedText = '';
        typeWriterEffect();
    }

    function selectButton(index: number, id?: string | number) {
        finish = false;
        SendEvent('dialog:click', {
            index,
            id,
            ped_id
        })
    }

    ReceiveEvent(Receive.showDialogue, (data: ShowDialogueData) => {
        currentDialogue = data.dialog;
        rep = data.rep;
        ped_id = data.ped_id
        refreshText();
    });
    console.log(rep)
    console.log(ped_id)
    ReceiveEvent(Receive.updateDialogue,(data: { type: string; value: string | Buttons[] }) => {
        currentDialogue = { ...currentDialogue, [data.type]: data.value }
        if (data.type === 'text') refreshText()
    });
</script>

<div class="w-full h-[60%] absolute bg-gradient-to-t from-black to-transparent"></div>
<div class="w-[35%] h-[40%] z-10">
    <p class="text-[#5e5cf4] font-[700]">{currentDialogue.job} - {rep}Rep</p>
    <p class="text-white text-[36px] font-[700]">{currentDialogue.name}</p>

    <div class="dialog-background">
        <p>{displayedText}</p>
    </div>

    <div class="grid grid-cols-2 gap-4 w-[100%] mt-5 px-7">
        {#if finish}
            {#each currentDialogue.buttons as item, index}
                <button
                    on:click={() => selectButton(index + 1, item.id)}
                    class="dialog-button flex items-center gap-5"
                    disabled={item.reqRep > rep}>
                    <img src={HexSVG} alt="Hex Icon" width="18" height="18" />
                    {item.label}
                </button>
            {/each}
        {/if}
    </div>
</div>

<style>
    .dialog-button:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }
</style>
