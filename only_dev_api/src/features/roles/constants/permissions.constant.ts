export interface PermissionDefinition {
  key: string;
  category: string;
  name: string;
  description: string;
}

export const PLATFORM_PERMISSIONS: PermissionDefinition[] = [
  // Course Management
  {
    key: 'courses:read_published',
    category: 'Courses',
    name: 'Browse Published Courses',
    description: 'View active catalog courses',
  },
  {
    key: 'courses:create',
    category: 'Courses',
    name: 'Create Courses',
    description: 'Create new course drafts and sections',
  },
  {
    key: 'courses:update_own',
    category: 'Courses',
    name: 'Update Own Courses',
    description: 'Edit curriculum, metadata, and lessons for courses created by user',
  },
  {
    key: 'courses:update_any',
    category: 'Courses',
    name: 'Update Any Course',
    description: 'Edit any course on the entire platform',
  },
  {
    key: 'courses:publish',
    category: 'Courses',
    name: 'Publish Courses',
    description: 'Approve and publish draft courses to the catalog',
  },
  {
    key: 'courses:delete_any',
    category: 'Courses',
    name: 'Delete Any Course',
    description: 'Permanently remove courses and related curriculum',
  },

  // Media & Storage
  {
    key: 'storage:upload_video',
    category: 'Media',
    name: 'Upload Lesson Videos',
    description: 'Obtain presigned upload URLs for Cloudflare R2 video storage',
  },
  {
    key: 'storage:upload_attachment',
    category: 'Media',
    name: 'Upload Course Attachments',
    description: 'Upload PDF and resource files to R2',
  },

  // Enrollments
  {
    key: 'enrollments:create',
    category: 'Enrollments',
    name: 'Enroll in Courses',
    description: 'Self-enroll in free or paid courses',
  },
  {
    key: 'enrollments:manage_any',
    category: 'Enrollments',
    name: 'Manage All Enrollments',
    description: 'Grant access, revoke, or refund student course enrollments',
  },

  // Quizzes & Assessments
  {
    key: 'quizzes:attempt',
    category: 'Quizzes',
    name: 'Take Quizzes',
    description: 'Submit quiz attempts and receive grades',
  },
  {
    key: 'quizzes:manage_own',
    category: 'Quizzes',
    name: 'Create & Manage Own Quizzes',
    description: 'Add and edit quiz questions in owned courses',
  },
  {
    key: 'quizzes:grade',
    category: 'Quizzes',
    name: 'Grade Submissions',
    description: 'Review and grade student quiz submissions',
  },

  // User Management
  {
    key: 'users:read',
    category: 'Users',
    name: 'View Users List',
    description: 'Browse registered platform users',
  },
  {
    key: 'users:manage_roles',
    category: 'Users',
    name: 'Assign User Roles',
    description: 'Assign or change user roles and custom permissions',
  },
  {
    key: 'users:ban',
    category: 'Users',
    name: 'Ban / Deactivate Users',
    description: 'Suspend user accounts',
  },

  // Roles & Custom RBAC Management
  {
    key: 'roles:read',
    category: 'Roles & RBAC',
    name: 'View Roles',
    description: 'List available roles and their permission sets',
  },
  {
    key: 'roles:manage',
    category: 'Roles & RBAC',
    name: 'Create & Modify Roles',
    description: 'Create custom roles and modify assigned permissions',
  },

  // Analytics & Reports
  {
    key: 'analytics:view',
    category: 'Analytics',
    name: 'Platform Analytics',
    description: 'View revenue, student enrollment, and completion metrics',
  },
];

