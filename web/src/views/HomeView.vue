<template>
  <a-layout>
    <a-layout-sider width="200" style="background: #fff">
      <a-menu
          mode="inline"

          :style="{ height: '100%', borderRight: 0 }"
      >
        <a-sub-menu key="sub1">
          <template #title>
              <span>
                <user-outlined />
                subnav 1
              </span>
          </template>
          <a-menu-item key="1">option1</a-menu-item>
          <a-menu-item key="2">option2</a-menu-item>
          <a-menu-item key="3">option3</a-menu-item>
          <a-menu-item key="4">option4</a-menu-item>
        </a-sub-menu>
        <a-sub-menu key="sub2">
          <template #title>
              <span>
                <laptop-outlined />
                subnav 2
              </span>
          </template>
          <a-menu-item key="5">option5</a-menu-item>
          <a-menu-item key="6">option6</a-menu-item>
          <a-menu-item key="7">option7</a-menu-item>
          <a-menu-item key="8">option8</a-menu-item>
        </a-sub-menu>
        <a-sub-menu key="sub3">
          <template #title>
              <span>
                <notification-outlined />
                subnav 3
              </span>
          </template>
          <a-menu-item key="9">option9</a-menu-item>
          <a-menu-item key="10">option10</a-menu-item>
          <a-menu-item key="11">option11</a-menu-item>
          <a-menu-item key="12">option12</a-menu-item>
        </a-sub-menu>
      </a-menu>
    </a-layout-sider>
    <a-layout-content
        :style="{ background: '#fff', padding: '24px', margin: 0, minHeight: '280px' }"
    >

      <a-alert v-if="errorMessage" type="error" :message="errorMessage" show-icon style="margin-bottom: 16px" />
      <a-list item-layout="vertical" size="large" :grid="{gutter:20,column:3}" row-key="id" :loading="loading" :pagination="pagination" :data-source="ebooks">

        <template #renderItem="{ item }">
          <a-list-item :key="item.id">
            <template #actions>
              <span><book-outlined /> {{ item.docCount ?? 0 }}</span>
              <span><eye-outlined /> {{ item.viewCount ?? 0 }}</span>
              <span><like-outlined /> {{ item.voteCount ?? 0 }}</span>
            </template>

            <a-list-item-meta :description="item.description">
              <template #title>
                <span>{{ item.name }}</span>
              </template>
              <template #avatar><a-avatar :src="item.cover" /></template>
            </a-list-item-meta>
          </a-list-item>
        </template>
      </a-list>

    </a-layout-content>
  </a-layout>
</template>

<script lang="ts">
import { defineComponent, onBeforeUnmount, onMounted, reactive, ref } from 'vue';
import axios from 'axios';

interface Ebook {
  id: number | string;
  name: string;
  description: string | null;
  cover: string | null;
  docCount: number | null;
  viewCount: number | null;
  voteCount: number | null;
}

interface EbookResponse {
  success: boolean;
  message?: string;
  content?: {
    list: Ebook[];
    total: number;
  };
}

export default defineComponent({
  name: 'HomeView',
  setup() {
    const ebooks = ref<Ebook[]>([]);
    const loading = ref(false);
    const errorMessage = ref('');
    let requestId = 0;

    const pagination = reactive({
      current: 1,
      pageSize: 30,
      total: 0,
      showSizeChanger: false,
      onChange: (page: number) => {
        void loadEbooks(page);
      },
    });

    async function loadEbooks(page: number) {
      const currentRequest = ++requestId;
      loading.value = true;
      errorMessage.value = '';
      try {
        const response = await axios.get<EbookResponse>('/ebook/list', {
          params: { name: '', page, size: pagination.pageSize },
        });
        if (currentRequest !== requestId) return;
        const data = response.data;
        if (!data.success || !data.content || !Array.isArray(data.content.list)) {
          throw new Error(data.message || '电子书列表返回格式不正确');
        }
        ebooks.value = data.content.list;
        pagination.total = data.content.total;
        pagination.current = page;
      } catch (error) {
        if (currentRequest !== requestId) return;
        errorMessage.value = error instanceof Error ? error.message : '电子书加载失败，请稍后重试';
      } finally {
        if (currentRequest === requestId) loading.value = false;
      }
    }

    onMounted(() => { void loadEbooks(1); });
    // Ignore outstanding responses after navigation or a newer request.
    onBeforeUnmount(() => { requestId++; });

    return { ebooks, loading, errorMessage, pagination };
  },
});
</script>
<style scoped>
.ant-avatar {
  width: 50px;
  height: 50px;
  line-height: 50px;
  border-radius: 8%;
  margin: 5px 0;
}
</style>