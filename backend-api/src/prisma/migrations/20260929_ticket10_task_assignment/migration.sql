-- Ticket 10: Task Assignment Module
-- Adds Task, TaskBatch, TaskDeadlineChange, TaskSubmission tables
-- Adds DeadlineType, TaskProgress enums
-- Adds TASK_UPDATE to NotificationType

-- CreateEnum
CREATE TYPE "DeadlineType" AS ENUM ('FIXED', 'TENTATIVE', 'TBD', 'NONE');

-- CreateEnum
CREATE TYPE "TaskProgress" AS ENUM ('NOT_STARTED', 'IN_PROGRESS', 'ALMOST_COMPLETED', 'COMPLETED');

-- AlterEnum
ALTER TYPE "NotificationType" ADD VALUE 'TASK_UPDATE';

-- CreateTable
CREATE TABLE "tasks" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "isMandatory" BOOLEAN NOT NULL DEFAULT true,
    "isInternal" BOOLEAN NOT NULL DEFAULT false,
    "maxMarks" DOUBLE PRECISION,
    "deadlineType" "DeadlineType" NOT NULL DEFAULT 'NONE',
    "deadline" TIMESTAMP(3),
    "deadlineNote" TEXT,
    "closedAt" TIMESTAMP(3),
    "createdById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tasks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "task_batches" (
    "taskId" TEXT NOT NULL,
    "batchId" TEXT NOT NULL,

    CONSTRAINT "task_batches_pkey" PRIMARY KEY ("taskId","batchId")
);

-- CreateTable
CREATE TABLE "task_deadline_changes" (
    "id" TEXT NOT NULL,
    "taskId" TEXT NOT NULL,
    "oldDeadlineType" "DeadlineType" NOT NULL,
    "newDeadlineType" "DeadlineType" NOT NULL,
    "oldDeadline" TIMESTAMP(3),
    "newDeadline" TIMESTAMP(3),
    "reason" TEXT,
    "changedById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "task_deadline_changes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "task_submissions" (
    "id" TEXT NOT NULL,
    "taskId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "progress" "TaskProgress" NOT NULL DEFAULT 'NOT_STARTED',
    "isInterested" BOOLEAN NOT NULL DEFAULT false,
    "completedAt" TIMESTAMP(3),
    "isLate" BOOLEAN,
    "marksAwarded" DOUBLE PRECISION,
    "gradedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "task_submissions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "task_submissions_taskId_studentId_key" ON "task_submissions"("taskId", "studentId");

-- AddForeignKey
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_batches" ADD CONSTRAINT "task_batches_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "tasks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_batches" ADD CONSTRAINT "task_batches_batchId_fkey" FOREIGN KEY ("batchId") REFERENCES "batches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_deadline_changes" ADD CONSTRAINT "task_deadline_changes_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "tasks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_deadline_changes" ADD CONSTRAINT "task_deadline_changes_changedById_fkey" FOREIGN KEY ("changedById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_submissions" ADD CONSTRAINT "task_submissions_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "tasks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_submissions" ADD CONSTRAINT "task_submissions_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_submissions" ADD CONSTRAINT "task_submissions_gradedById_fkey" FOREIGN KEY ("gradedById") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
