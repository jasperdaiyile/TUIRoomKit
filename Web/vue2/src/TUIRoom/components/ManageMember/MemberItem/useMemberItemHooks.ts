import { ref, nextTick } from 'vue';
import { useRoomStore } from '../../../stores/room';
import { storeToRefs } from 'pinia';


export default function useMemberItem() {
  const roomStore = useRoomStore();
  const { isMaster } = storeToRefs(roomStore);

  const showMemberControl = ref(false);

  function handleMouseEnter() {
    if (isMaster.value) {
      showMemberControl.value = true;
    }
  }

  function handleMouseLeave() {
    showMemberControl.value = false;
  }

  const memberItemEl = ref();
  function setMemberItemRef(el: any) {
    memberItemEl.value = el;
  }

  const memberInfoEl = ref();
  const MemberControlEl = ref();
  function setMemberInfoRef(el: any) {
    memberInfoEl.value = el;
  }
  function setMemberControlRef(el: any) {
    MemberControlEl.value = el;
  }

  function handleMemberItemClick() {
    if (isMaster.value && !showMemberControl.value) {
      showMemberControl.value = true;
    }
  }
  async function handleCloseControl() {
    await nextTick();
    showMemberControl.value = false;
  }

  function handleDocumentClick(event: MouseEvent) {
    if (showMemberControl.value && memberItemEl.value && !memberItemEl.value.contains(event.target)) {
      showMemberControl.value = false;
    }
  }


  return {
    showMemberControl,
    handleMouseEnter,
    handleMouseLeave,
    setMemberItemRef,
    setMemberInfoRef,
    setMemberControlRef,
    handleMemberItemClick,
    handleDocumentClick,
    handleCloseControl,
  };
}


