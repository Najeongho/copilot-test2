<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
  </div>
</template>

<script>
export default {
  name: 'HelloWorld',
  data() {
    return {
      msg: 'Hello, Vue.js!'
    }
  }
}
</script>

<style scoped>
h1 {
  color: #42b983;
}
</style>