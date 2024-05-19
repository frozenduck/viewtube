<template>
  <div class="popup">
    <div class="container popup-container" :class="{ loading: loading }">
      <div class="form-header">
        <VTIcon
          v-ripple
          name="mdi:close"
          class="close-icon"
          @click.stop="$emit('usernameChangeClose')"
        />
        <h2 class="form-title">Change username</h2>
      </div>
      <Spinner />
      <form id="form" method="post" @submit.prevent="changeUsername">
        <FormInput
          :id="'oldUsername'"
          v-model="oldUsername"
          :label="'Old Username'"
          :type="'text'"
        />
        <FormInput
          :id="'newUsername'"
          v-model="newUsername"
          :label="'New Username'"
          :type="'text'"
        />
        <FormInput
          :id="'newUsernameConfirm'"
          v-model="newUsernameConfirm"
          :label="'Confirm new username'"
          :type="'text'"
        />
        <SubmitButton :label="'Change username'" />
      </form>
    </div>
    <div class="popup-overlay" @click.stop="$emit('usernameChangeClose')" />
  </div>
</template>

<script lang="ts">
import FormInput from '@/components/form/FormInput.vue';
import SubmitButton from '@/components/form/SubmitButton.vue';
import Spinner from '@/components/Spinner.vue';
import '@/assets/styles/popup.scss';
import { useMessagesStore } from '@/store/messages';
import { useUserStore } from '@/store/user';

export default defineComponent({
  name: 'UsernameChangeForm',
  components: {
    FormInput,
    SubmitButton,
    Spinner
  },
  setup(_props, { emit }) {
    const router = useRouter();
    const messagesStore = useMessagesStore();
    const userStore = useUserStore();
    const { apiUrl } = useApiUrl();
    const { vtFetch } = useVtFetch();

    const oldUsername = ref('');
    const newUsername = ref('');
    const newUsernameConfirm = ref('');
    const loading = ref(false);

    const changeUsername = () => {
      loading.value = true;
      if (newUsername.value !== newUsernameConfirm.value) {
        messagesStore.createMessage({
          type: 'error',
          title: 'Username change failed',
          message: 'The new username and the confirmation username do not match'
        });
        loading.value = false;
        return;
      }
      vtFetch(`${apiUrl.value}user/profile/username`, {
        method: 'POST',
        body: {
          username: userStore.username,
          newUsername: newUsername.value
        },
        credentials: 'include'
      })
        .then(() => {
          messagesStore.createMessage({
            type: 'info',
            title: 'Username changed',
            message: 'Your username has been changed'
          });
          loading.value = false;
          emit('usernameChangeClose');
        })
        .catch(error => {
          messagesStore.createMessage({
            type: 'error',
            title: 'Username change failed',
            message: error.message
          });
          loading.value = false;
        }).then(() => {
          setTimeout(() => {
            userStore.logout();
            router.push('/');
          }, 600);
      });
    };
    return {
      oldUsername,
      newUsername,
      newUsernameConfirm,
      changeUsername,
      loading
    };
  }
});
</script>

<style lang="scss" scoped>
.container {
  margin: auto;
  height: auto;

  .form-title {
    margin: 20px 0 0 0;
    font-size: 2rem;
    color: var(--theme-color);
    font-family: $default-font;
  }

  .message-display {
    height: 20px;
    line-height: 20px;
  }

  .hint {
    width: calc(100% - 80px);
    margin: 15px 0 0 0;
  }

  &.loading {
    .hint,
    #form {
      opacity: 0;
      pointer-events: none;
    }

    .spinner {
      opacity: 1;
    }
  }

  .spinner {
    position: absolute !important;
    top: 50%;
    transform: translateY(-50%);
    opacity: 0;
    transition: opacity 300ms $intro-easing;
  }

  #form {
    display: flex;
    flex-direction: column;
    width: calc(100% - 20px);
    max-width: 700px;
    padding: 10px;
    box-sizing: border-box;
    transition: opacity 300ms $intro-easing;
  }

  .close-icon {
    position: absolute;
  }
}
</style>
