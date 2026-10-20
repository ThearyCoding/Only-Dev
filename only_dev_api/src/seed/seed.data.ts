/**
 * Comprehensive Seed Data for Only-Dev Platform
 * 
 * Includes:
 * - Dynamic Roles & Permissions
 * - Instructors, Admins, and Student Accounts
 * - Course Categories with Unsplash HD images & BlurHashes
 * - Promotional Banners for Home Screen Carousel
 * - Production Courses with Curriculum, Sections & Lessons
 * - Real, Verified 200 OK Streaming MP4 & HLS Videos
 * - Interactive Quizzes with Questions & Options
 * - Active Enrollments & Video Playback Progress
 */

export interface SeedVideoLesson {
  title: string;
  type: 'video' | 'article' | 'quiz' | 'resource';
  isFreePreview: boolean;
  videoUrl: string;
  hlsUrl?: string;
  durationSeconds: number;
  thumbnailUrl: string;
  articleContent?: string;
}

export interface SeedSection {
  title: string;
  learningObjective: string;
  lessons: SeedVideoLesson[];
}

export interface SeedCourse {
  title: string;
  slug: string;
  shortDescription: string;
  description: string;
  thumbnailUrl: string;
  blurHash: string;
  level: 'beginner' | 'intermediate' | 'advanced' | 'all_levels';
  categorySlug: string;
  tags: string[];
  price: number;
  currency: string;
  discountPercentage: number;
  status: 'published' | 'draft';
  ratingAvg: number;
  ratingCount: number;
  enrollmentCounts: number;
  instructorEmail: string;
  sections: SeedSection[];
}

// ==========================================
// 1. Categories
// ==========================================
export const SEED_CATEGORIES = [
  {
    title: 'Mobile Development',
    slug: 'mobile-development',
    imageUrl: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?auto=format&fit=crop&w=600&q=80',
    blurHash: 'L7B:g6-;_3%M00_3%Mxu00WBofWB',
    order: 1,
  },
  {
    title: 'Web Development',
    slug: 'web-development',
    imageUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=600&q=80',
    blurHash: 'L66j[d~q00%M00_3%Mxu00WBofWB',
    order: 2,
  },
  {
    title: 'Cloud & DevOps',
    slug: 'cloud-devops',
    imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80',
    blurHash: 'L98qj^%M00_300%MxuWB00WBofWB',
    order: 3,
  },
  {
    title: 'UI/UX Design',
    slug: 'ui-ux-design',
    imageUrl: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?auto=format&fit=crop&w=600&q=80',
    blurHash: 'LA8qj^%M00_300%MxuWB00WBofWB',
    order: 4,
  },
  {
    title: 'Artificial Intelligence',
    slug: 'artificial-intelligence',
    imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780efad99a?auto=format&fit=crop&w=600&q=80',
    blurHash: 'LB8qj^%M00_300%MxuWB00WBofWB',
    order: 5,
  },
];

// ==========================================
// 2. Promotional Banners
// ==========================================
export const SEED_BANNERS = [
  {
    imageUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=1200&q=80',
    targetUrl: '/courses',
    order: 1,
  },
  {
    imageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=1200&q=80',
    targetUrl: '/courses',
    order: 2,
  },
  {
    imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=1200&q=80',
    targetUrl: '/courses',
    order: 3,
  },
  {
    imageUrl: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=1200&q=80',
    targetUrl: '/courses',
    order: 4,
  },
];

// ==========================================
// 3. User Accounts (Instructors, Admin, Student)
// ==========================================
export const SEED_USERS = [
  {
    email: 'admin@onlydev.com',
    fullName: 'Alex Thorne',
    role: 'SUPER_ADMIN',
    headline: 'Lead System Architect & Platform Admin',
    bio: 'Platform Administrator and Core Contributor to Only-Dev learning systems.',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    phoneNumber: '+14155550100',
  },
  {
    email: 'angela@onlydev.com',
    fullName: 'Dr. Angela Yu',
    role: 'INSTRUCTOR',
    headline: 'Lead Mobile Instructor & Google Developer Expert',
    bio: 'Developer, educator, and Flutter advocate who has taught over 1,000,000 students worldwide.',
    avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
    phoneNumber: '+14155550101',
  },
  {
    email: 'brad@onlydev.com',
    fullName: 'Brad Traversy',
    role: 'INSTRUCTOR',
    headline: 'Full-Stack Web & Cloud Infrastructure Specialist',
    bio: 'Passionate web developer and content creator covering modern backend, frontend, and DevOps architectures.',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
    phoneNumber: '+14155550102',
  },
  {
    email: 'sarah@onlydev.com',
    fullName: 'Sarah Connor',
    role: 'INSTRUCTOR',
    headline: 'Principal Product Designer & Design Systems Lead',
    bio: 'Designing modern digital experiences, design tokens, and human-computer interaction patterns.',
    avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=400&q=80',
    phoneNumber: '+14155550103',
  },
  {
    email: 'student@onlydev.com',
    fullName: 'Theary Chorn',
    role: 'STUDENT',
    headline: 'Aspiring Mobile & Cloud Engineer',
    bio: 'Passionate learner building mobile and web apps with Flutter, Riverpod, and NestJS.',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
    phoneNumber: '+14155550104',
  },
];

// ==========================================
// 4. Real, Tested Video URLs
// All verified HTTP/2 200 with video/mp4 & audio/mpegurl
// ==========================================
export const REAL_VIDEOS = {
  // VideoJS Oceans (HD 1080p, 46s)
  oceans: {
    rawUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
    durationSeconds: 46,
    thumbnailUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=600&q=80',
  },
  // W3C Sintel Trailer (HD, 52s)
  sintel: {
    rawUrl: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
    durationSeconds: 52,
    thumbnailUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&w=600&q=80',
  },
  // Plyr Surf Trailer 720p (135s)
  surf720p: {
    rawUrl: 'https://cdn.plyr.io/static/demo/View_From_A_Blue_Moon_Trailer-720p.mp4',
    durationSeconds: 135,
    thumbnailUrl: 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?auto=format&fit=crop&w=600&q=80',
  },
  // Plyr Surf Trailer 576p (135s)
  surf576p: {
    rawUrl: 'https://cdn.plyr.io/static/demo/View_From_A_Blue_Moon_Trailer-576p.mp4',
    durationSeconds: 135,
    thumbnailUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
  },
  // MDN Flower Demo (5s, quick test)
  flower: {
    rawUrl: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
    durationSeconds: 5,
    thumbnailUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=600&q=80',
  },
  // MDN Friday Demo (10s, quick test)
  friday: {
    rawUrl: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/friday.mp4',
    durationSeconds: 10,
    thumbnailUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=600&q=80',
  },
  // Mux Adaptive HLS Stream (Big Buck Bunny)
  muxHls: {
    rawUrl: 'https://vjs.zencdn.net/v/oceans.mp4',
    hlsUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    durationSeconds: 596,
    thumbnailUrl: 'https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?auto=format&fit=crop&w=600&q=80',
  },
};

// ==========================================
// 5. Courses with Full Curriculum & Real Videos
// ==========================================
export const SEED_COURSES: SeedCourse[] = [
  {
    title: 'Master Flutter 3.24 & Riverpod: From Scratch to Production',
    slug: 'master-flutter-3-riverpod-production',
    shortDescription: 'Build production-ready cross-platform apps with Riverpod 2.6, Clean Architecture, and Dio.',
    description: `Take your mobile app development skills to the next level with this comprehensive, hands-on masterclass. 
You will learn Flutter 3.24+, StateNotifier and AsyncNotifier architecture, complete elimination of setState, and integration with modern NestJS REST APIs and Cloudflare R2 video streaming.

Key Highlights:
- Riverpod 2.6 State Management Architecture
- Zero setState rule and declarative Consumer widgets
- Custom Dio Client with Auth and Error Interceptors
- High-Performance BetterPlayer video streaming with playback resume
- Offline caching and resilient local data persistence`,
    thumbnailUrl: 'https://images.unsplash.com/photo-1551650975-87deedd944c3?auto=format&fit=crop&w=800&q=80',
    blurHash: 'L7B:g6-;_3%M00_3%Mxu00WBofWB',
    level: 'all_levels',
    categorySlug: 'mobile-development',
    tags: ['Flutter', 'Riverpod', 'Dart', 'Mobile', 'iOS', 'Android'],
    price: 49.99,
    currency: 'USD',
    discountPercentage: 20,
    status: 'published',
    ratingAvg: 4.9,
    ratingCount: 342,
    enrollmentCounts: 1250,
    instructorEmail: 'angela@onlydev.com',
    sections: [
      {
        title: 'Section 1: Foundations & Architecture Setup',
        learningObjective: 'Understand the architectural rules, eliminate setState, and setup Riverpod 2.6 and Dio.',
        lessons: [
          {
            title: '1.1 Course Welcome & Setting Up Flutter 3.24',
            type: 'video',
            isFreePreview: true,
            videoUrl: REAL_VIDEOS.oceans.rawUrl,
            durationSeconds: REAL_VIDEOS.oceans.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.oceans.thumbnailUrl,
          },
          {
            title: '1.2 Why Riverpod 2.6? Goodbye setState Forever!',
            type: 'video',
            isFreePreview: true,
            videoUrl: REAL_VIDEOS.surf720p.rawUrl,
            durationSeconds: REAL_VIDEOS.surf720p.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.surf720p.thumbnailUrl,
          },
          {
            title: '1.3 Configuring Dio Client with Interceptors & JWT Auth',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.sintel.rawUrl,
            durationSeconds: REAL_VIDEOS.sintel.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.sintel.thumbnailUrl,
          },
        ],
      },
      {
        title: 'Section 2: Reactive State Management with Riverpod',
        learningObjective: 'Build decoupled UI screens with StateNotifierProvider, FutureProvider, and ConsumerWidget.',
        lessons: [
          {
            title: '2.1 StateNotifier vs AsyncNotifier: When and How to Use Each',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.surf576p.rawUrl,
            durationSeconds: REAL_VIDEOS.surf576p.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.surf576p.thumbnailUrl,
          },
          {
            title: '2.2 Declarative Forms without Controllers Leaks',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.friday.rawUrl,
            durationSeconds: REAL_VIDEOS.friday.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.friday.thumbnailUrl,
          },
        ],
      },
      {
        title: 'Section 3: Cloud Video Streaming & BetterPlayer Integration',
        learningObjective: 'Integrate adaptive HLS/MP4 video player and auto-resume playback positions from NestJS API.',
        lessons: [
          {
            title: '3.1 BetterPlayer Configuration & Custom Overlay Controls',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.muxHls.rawUrl,
            hlsUrl: REAL_VIDEOS.muxHls.hlsUrl,
            durationSeconds: REAL_VIDEOS.muxHls.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.muxHls.thumbnailUrl,
          },
          {
            title: '3.2 Uploading Videos & Images to Cloudflare R2 Presigned URLs',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.oceans.rawUrl,
            durationSeconds: REAL_VIDEOS.oceans.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.oceans.thumbnailUrl,
          },
        ],
      },
    ],
  },
  {
    title: 'Modern Full-Stack NestJS, GraphQL & Microservices',
    slug: 'modern-fullstack-nestjs-microservices',
    shortDescription: 'Master scalable server-side TypeScript with NestJS, MongoDB, Redis Caching, and dynamic RBAC.',
    description: `Build robust, enterprise-grade backend APIs with NestJS 12+, MongoDB, Redis, and Cloudflare R2.
Learn how to implement dynamic role-based access control, composite BFF endpoints for mobile apps, and direct S3 presigned uploads.

Topics Covered:
- Modular Architecture and Clean Inversion of Control
- Dynamic RBAC with Redis permission caching
- MongoDB Compound Indexes & Aggregation Pipelines
- Screen-Aggregated BFF Endpoints (Single Screen = Single Endpoint)
- AWS S3 / Cloudflare R2 Presigned Uploads`,
    thumbnailUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=800&q=80',
    blurHash: 'L66j[d~q00%M00_3%Mxu00WBofWB',
    level: 'intermediate',
    categorySlug: 'web-development',
    tags: ['NestJS', 'TypeScript', 'Node.js', 'MongoDB', 'Redis', 'Backend'],
    price: 59.99,
    currency: 'USD',
    discountPercentage: 15,
    status: 'published',
    ratingAvg: 4.8,
    ratingCount: 210,
    enrollmentCounts: 890,
    instructorEmail: 'brad@onlydev.com',
    sections: [
      {
        title: 'Section 1: NestJS Core & Clean Architecture',
        learningObjective: 'Master NestJS Dependency Injection, Controllers, Services, and Custom Decorators.',
        lessons: [
          {
            title: '1.1 Deep Dive: NestJS Modules & Providers',
            type: 'video',
            isFreePreview: true,
            videoUrl: REAL_VIDEOS.sintel.rawUrl,
            durationSeconds: REAL_VIDEOS.sintel.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.sintel.thumbnailUrl,
          },
          {
            title: '1.2 Dynamic RBAC: Custom Roles & Redis Permission Cache',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.oceans.rawUrl,
            durationSeconds: REAL_VIDEOS.oceans.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.oceans.thumbnailUrl,
          },
        ],
      },
      {
        title: 'Section 2: MongoDB Performance & Aggregation',
        learningObjective: 'Design compound indexes, transactions, and aggregate pipelines.',
        lessons: [
          {
            title: '2.1 Mongoose Schema Design with Unified Tables',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.surf720p.rawUrl,
            durationSeconds: REAL_VIDEOS.surf720p.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.surf720p.thumbnailUrl,
          },
          {
            title: '2.2 Building Screen-Aggregated Composite Endpoints',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.flower.rawUrl,
            durationSeconds: REAL_VIDEOS.flower.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.flower.thumbnailUrl,
          },
        ],
      },
    ],
  },
  {
    title: 'Docker, Kubernetes & Cloud Architecture from Scratch',
    slug: 'docker-kubernetes-cloud-architecture',
    shortDescription: 'Containerize applications, orchestrate Kubernetes clusters, and automate CI/CD pipelines.',
    description: `From local Docker containers to multi-node Kubernetes clusters and automated CI/CD pipelines.
Learn the essentials of production cloud infrastructure with hands-on labs.

Key Skills:
- Dockerfile optimization and multi-stage builds
- Docker Compose local development environments
- Kubernetes Pods, Deployments, Services, and Ingress
- Helm Charts and automated deployments`,
    thumbnailUrl: 'https://images.unsplash.com/photo-1607799279861-4dd421887fb3?auto=format&fit=crop&w=800&q=80',
    blurHash: 'L98qj^%M00_300%MxuWB00WBofWB',
    level: 'advanced',
    categorySlug: 'cloud-devops',
    tags: ['Docker', 'Kubernetes', 'DevOps', 'AWS', 'Cloud', 'CI/CD'],
    price: 69.99,
    currency: 'USD',
    discountPercentage: 30,
    status: 'published',
    ratingAvg: 4.95,
    ratingCount: 415,
    enrollmentCounts: 1560,
    instructorEmail: 'brad@onlydev.com',
    sections: [
      {
        title: 'Section 1: Containerization with Docker',
        learningObjective: 'Package modern Node.js and Flutter web apps into minimal, secure Docker images.',
        lessons: [
          {
            title: '1.1 Multi-Stage Production Dockerfiles',
            type: 'video',
            isFreePreview: true,
            videoUrl: REAL_VIDEOS.surf720p.rawUrl,
            durationSeconds: REAL_VIDEOS.surf720p.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.surf720p.thumbnailUrl,
          },
          {
            title: '1.2 Orchestrating Local Microservices with Docker Compose',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.friday.rawUrl,
            durationSeconds: REAL_VIDEOS.friday.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.friday.thumbnailUrl,
          },
        ],
      },
      {
        title: 'Section 2: Kubernetes Orchestration',
        learningObjective: 'Deploy and scale microservices on Kubernetes.',
        lessons: [
          {
            title: '2.1 Deployments, ReplicaSets & Rolling Updates',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.oceans.rawUrl,
            durationSeconds: REAL_VIDEOS.oceans.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.oceans.thumbnailUrl,
          },
        ],
      },
    ],
  },
  {
    title: 'Figma UI/UX Design System Pro: Concept to Code',
    slug: 'figma-ui-ux-design-system-pro',
    shortDescription: 'Design modern responsive mobile & web interfaces, design tokens, and interactive prototypes.',
    description: `Master Figma, Design Systems, and design handoff to Flutter & React developers.
Learn how to build reusable component libraries, auto-layout grids, interactive prototypes, and cohesive color schemes.`,
    thumbnailUrl: 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?auto=format&fit=crop&w=800&q=80',
    blurHash: 'LA8qj^%M00_300%MxuWB00WBofWB',
    level: 'beginner',
    categorySlug: 'ui-ux-design',
    tags: ['Figma', 'UI/UX', 'Design', 'Mobile UI', 'Web Design'],
    price: 39.99,
    currency: 'USD',
    discountPercentage: 10,
    status: 'published',
    ratingAvg: 4.85,
    ratingCount: 180,
    enrollmentCounts: 720,
    instructorEmail: 'sarah@onlydev.com',
    sections: [
      {
        title: 'Section 1: Design Tokens & Typography Systems',
        learningObjective: 'Establish scalable typography scales, color hierarchies, and accessibility standards.',
        lessons: [
          {
            title: '1.1 Typography Hierarchy & WCAG Contrast Rules',
            type: 'video',
            isFreePreview: true,
            videoUrl: REAL_VIDEOS.sintel.rawUrl,
            durationSeconds: REAL_VIDEOS.sintel.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.sintel.thumbnailUrl,
          },
          {
            title: '1.2 Advanced Auto-Layout & Fluid Component Variants',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.flower.rawUrl,
            durationSeconds: REAL_VIDEOS.flower.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.flower.thumbnailUrl,
          },
        ],
      },
    ],
  },
  {
    title: 'Applied AI & LLMs with Python: Building Production Agents',
    slug: 'applied-ai-llms-python-production-agents',
    shortDescription: 'Build production-grade AI agents, RAG systems, and function-calling pipelines.',
    description: `Learn how to integrate LLMs, vector databases, and multi-agent workflows into real-world applications.
Hands-on projects with LangChain, LlamaIndex, embeddings, and semantic search.`,
    thumbnailUrl: 'https://images.unsplash.com/photo-1677442136019-21780efad99a?auto=format&fit=crop&w=800&q=80',
    blurHash: 'LB8qj^%M00_300%MxuWB00WBofWB',
    level: 'intermediate',
    categorySlug: 'artificial-intelligence',
    tags: ['Python', 'AI', 'LLM', 'Machine Learning', 'Agents', 'RAG'],
    price: 79.99,
    currency: 'USD',
    discountPercentage: 25,
    status: 'published',
    ratingAvg: 5.0,
    ratingCount: 520,
    enrollmentCounts: 2100,
    instructorEmail: 'angela@onlydev.com',
    sections: [
      {
        title: 'Section 1: LLM Tool Calling & Agent Architectures',
        learningObjective: 'Understand how autonomous agents execute tools and maintain memory.',
        lessons: [
          {
            title: '1.1 Autonomous Agents & Function Calling Patterns',
            type: 'video',
            isFreePreview: true,
            videoUrl: REAL_VIDEOS.surf720p.rawUrl,
            durationSeconds: REAL_VIDEOS.surf720p.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.surf720p.thumbnailUrl,
          },
          {
            title: '1.2 Production RAG: Chunking, Embeddings & Vector Search',
            type: 'video',
            isFreePreview: false,
            videoUrl: REAL_VIDEOS.oceans.rawUrl,
            durationSeconds: REAL_VIDEOS.oceans.durationSeconds,
            thumbnailUrl: REAL_VIDEOS.oceans.thumbnailUrl,
          },
        ],
      },
    ],
  },
];

// ==========================================
// 6. Interactive Quizzes
// ==========================================
export const SEED_QUIZZES = [
  {
    courseSlug: 'master-flutter-3-riverpod-production',
    title: 'Flutter & Riverpod Knowledge Evaluation',
    passingScorePercent: 70,
    timeLimitMinutes: 15,
    maxAttemptsAllowed: 3,
    shuffleQuestions: true,
    questions: [
      {
        prompt: 'Which Riverpod provider is best suited for asynchronous network operations with automated caching & refresh?',
        type: 'single_choice',
        points: 10,
        options: [
          { id: 'opt_1', text: 'FutureProvider', isCorrect: true, explanation: 'FutureProvider automatically handles async loading, data, and error states.' },
          { id: 'opt_2', text: 'StateProvider', isCorrect: false, explanation: 'StateProvider is designed for simple synchronous primitive state.' },
          { id: 'opt_3', text: 'ChangeNotifierProvider', isCorrect: false, explanation: 'ChangeNotifierProvider is a legacy pattern and not recommended for async pipelines.' },
          { id: 'opt_4', text: 'StreamProvider', isCorrect: false, explanation: 'StreamProvider is for persistent continuous streams (e.g. WebSockets), not standard HTTP calls.' },
        ],
      },
      {
        prompt: 'What is our primary architectural rule regarding setState in the mobile app?',
        type: 'single_choice',
        points: 10,
        options: [
          { id: 'opt_1', text: 'Never use setState in UI views; manage state reactively via Riverpod Notifiers', isCorrect: true, explanation: 'Rule 3 mandates zero setState for UI state management.' },
          { id: 'opt_2', text: 'Use setState only inside dialogs', isCorrect: false, explanation: 'Dialogs must also consume reactive providers.' },
          { id: 'opt_3', text: 'Use setState for network operations', isCorrect: false, explanation: 'Network operations must be driven by repositories and Notifiers.' },
          { id: 'opt_4', text: 'setState is recommended everywhere', isCorrect: false, explanation: 'setState causes tight coupling and memory leaks.' },
        ],
      },
      {
        prompt: 'Where should direct repository and service calls (e.g. locator<Repository>()) reside?',
        type: 'single_choice',
        points: 10,
        options: [
          { id: 'opt_1', text: 'Inside Riverpod Notifiers and ViewModels, never directly in UI widgets', isCorrect: true, explanation: 'Rule 1 strictly forbids calling repos or services directly inside UI widgets.' },
          { id: 'opt_2', text: 'Directly in the build() method of StatefulWidget', isCorrect: false, explanation: 'This creates massive performance bottlenecks and triggers infinite network calls.' },
          { id: 'opt_3', text: 'Inside MaterialApp main() only', isCorrect: false, explanation: 'Main is only for application initialization.' },
          { id: 'opt_4', text: 'In assets/ configuration files', isCorrect: false, explanation: 'Assets are static bundled resources.' },
        ],
      },
    ],
  },
];

