import prisma from '../lib/prisma';

export interface TaskStats {
  missedCount: number;
  lateCount: number;
  totalMandatory: number;
}

export async function getTaskStats(
  studentId: string,
  batchId: string,
): Promise<TaskStats | null> {
  const taskBatches = await prisma.taskBatch.findMany({
    where: { batchId },
    select: { taskId: true },
  });

  if (taskBatches.length === 0) return null;

  const taskIds = taskBatches.map((tb) => tb.taskId);

  const mandatoryTasks = await prisma.task.findMany({
    where: {
      id: { in: taskIds },
      isMandatory: true,
      closedAt: null,
    },
    select: { id: true, deadlineType: true, deadline: true },
  });

  if (mandatoryTasks.length === 0) return null;

  const mandatoryTaskIds = mandatoryTasks.map((t) => t.id);

  const submissions = await prisma.taskSubmission.findMany({
    where: {
      studentId,
      taskId: { in: mandatoryTaskIds },
    },
    select: { taskId: true, progress: true, isLate: true },
  });

  const submissionMap = new Map(submissions.map((s) => [s.taskId, s]));
  const now = new Date();

  let missedCount = 0;
  let lateCount = 0;

  for (const task of mandatoryTasks) {
    const sub = submissionMap.get(task.id);

    if (task.deadlineType === 'FIXED' && task.deadline && task.deadline < now) {
      if (!sub || sub.progress !== 'COMPLETED') {
        missedCount++;
      } else if (sub.isLate) {
        lateCount++;
      }
    } else if (sub?.isLate) {
      lateCount++;
    }
  }

  return {
    missedCount,
    lateCount,
    totalMandatory: mandatoryTasks.length,
  };
}
