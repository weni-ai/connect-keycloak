Vue.component('modal-dialog', {
  props: {
    text: String,      
    modalIcon: String, 
    scheme: String,   
    show: {             
      type: Boolean,
      default: false
    }
  },
  template: `
    <div v-if="show" class="modal-dialog-overlay" @mousedown.self="closeDialog">
      <div class="modal-dialog-content" :class="schemeClasses">
        <button class="modal-dialog-close-button" @click="closeDialog" aria-label="Close modal">
          <unnnic-icon icon="close-1" size="md"></unnnic-icon>
        </button>
        <div v-if="modalIcon" class="modal-dialog-icon-wrapper">
          <span :class="iconFullClasses"></span>
        </div>
        <h2 v-if="text" class="modal-dialog-title-text">{{ text }}</h2>
        <div class="modal-dialog-separator"></div>
        <div class="modal-dialog-body-content">
          <slot name="message"></slot>
        </div>
        <div class="modal-dialog-actions">
          <slot name="actions"></slot>
        </div>
      </div>
    </div>
  `,
  computed: {
    schemeClasses() {
      const classes = {};
      if (this.scheme) {
        classes[`modal-dialog-scheme-${this.scheme}`] = true;
      }
      return classes;
    },
    iconFullClasses() {
      return this.modalIcon ? `unnnic-icon ${this.modalIcon}` : '';
    }
  },
  methods: {
    closeDialog() {
      this.$emit('close');
    }
  }
}); 