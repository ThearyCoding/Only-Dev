import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException, BadRequestException } from '@nestjs/common';
import mongoose from 'mongoose';
import { QuizzesService } from './quizzes.service.js';
import { Quiz } from '../schemas/quiz.schema.js';
import { QuizSubmission } from '../schemas/quiz-submission.schema.js';

describe('QuizzesService Unit Tests', () => {
  let service: QuizzesService;
  let mockQuizModel: any;
  let mockSubmissionModel: any;

  const validQuizId = new mongoose.Types.ObjectId().toString();
  const validCourseId = new mongoose.Types.ObjectId().toString();
  const validUserId = new mongoose.Types.ObjectId().toString();
  const validQuestionId1 = new mongoose.Types.ObjectId().toString();
  const validQuestionId2 = new mongoose.Types.ObjectId().toString();

  const sampleQuiz = {
    _id: validQuizId,
    title: 'Flutter & Riverpod Knowledge Evaluation',
    courseId: validCourseId,
    passingScorePercent: 70,
    timeLimitMinutes: 15,
    maxAttemptsAllowed: 3,
    shuffleQuestions: true,
    questions: [
      {
        _id: validQuestionId1,
        prompt: 'Which Riverpod provider is best for async operations?',
        type: 'single_choice',
        points: 10,
        options: [
          { id: 'opt_1', text: 'FutureProvider', isCorrect: true, explanation: 'Handles async states.' },
          { id: 'opt_2', text: 'StateProvider', isCorrect: false, explanation: 'For primitives.' },
        ],
      },
      {
        _id: validQuestionId2,
        prompt: 'What is our rule regarding setState?',
        type: 'single_choice',
        points: 10,
        options: [
          { id: 'opt_1', text: 'Zero setState in UI views', isCorrect: true, explanation: 'Mandated by Rule 3.' },
          { id: 'opt_2', text: 'Use setState everywhere', isCorrect: false, explanation: 'Causes leaks.' },
        ],
      },
    ],
  };

  beforeEach(async () => {
    // Mock Quiz Model as a constructor and with query methods
    function MockQuiz(data: any) {
      Object.assign(this, data);
      this.save = vi.fn().mockResolvedValue(sampleQuiz);
    }
    MockQuiz.find = vi.fn();
    MockQuiz.findById = vi.fn();
    mockQuizModel = MockQuiz;

    // Mock QuizSubmission Model as constructor and with query methods
    const submissionId = new mongoose.Types.ObjectId().toString();
    function MockSubmission(data: any) {
      Object.assign(this, data);
      this._id = submissionId;
      this.save = vi.fn().mockResolvedValue(true);
    }
    MockSubmission.countDocuments = vi.fn();
    MockSubmission.find = vi.fn();
    mockSubmissionModel = MockSubmission;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        QuizzesService,
        {
          provide: getModelToken(Quiz.name),
          useValue: mockQuizModel,
        },
        {
          provide: getModelToken(QuizSubmission.name),
          useValue: mockSubmissionModel,
        },
      ],
    }).compile();

    service = module.get<QuizzesService>(QuizzesService);
  });

  describe('findByCourseId', () => {
    it('returns quizzes associated with a course', async () => {
      mockQuizModel.find.mockReturnValue({
        exec: vi.fn().mockResolvedValue([sampleQuiz]),
      });

      const result = await service.findByCourseId(validCourseId);
      expect(result).toHaveLength(1);
      expect(result[0].title).toBe('Flutter & Riverpod Knowledge Evaluation');
      expect(mockQuizModel.find).toHaveBeenCalledWith({
        courseId: expect.any(mongoose.Types.ObjectId),
      });
    });
  });

  describe('getQuizForStudent', () => {
    it('throws NotFoundException when quiz does not exist', async () => {
      mockQuizModel.findById.mockReturnValue({
        lean: vi.fn().mockReturnValue({
          exec: vi.fn().mockResolvedValue(null),
        }),
      });

      await expect(service.getQuizForStudent('non_existent_id')).rejects.toThrow(NotFoundException);
    });

    it('masks isCorrect and explanation so students cannot inspect payload', async () => {
      mockQuizModel.findById.mockReturnValue({
        lean: vi.fn().mockReturnValue({
          exec: vi.fn().mockResolvedValue(sampleQuiz),
        }),
      });

      const sanitized = await service.getQuizForStudent(validQuizId);
      expect(sanitized.title).toBe(sampleQuiz.title);
      expect(sanitized.questions).toHaveLength(2);

      const firstQuestion = sanitized.questions[0];
      expect(firstQuestion.prompt).toBe(sampleQuiz.questions[0].prompt);
      expect(firstQuestion.options[0]).toEqual({
        id: 'opt_1',
        text: 'FutureProvider',
      });
      // Verification: isCorrect and explanation are stripped
      expect(firstQuestion.options[0]).not.toHaveProperty('isCorrect');
      expect(firstQuestion.options[0]).not.toHaveProperty('explanation');
    });
  });

  describe('submitAttempt', () => {
    it('throws NotFoundException if quiz is not found', async () => {
      mockQuizModel.findById.mockResolvedValue(null);

      await expect(
        service.submitAttempt(validQuizId, validUserId, { answers: [] }),
      ).rejects.toThrow(NotFoundException);
    });

    it('throws BadRequestException if student reached maximum attempts', async () => {
      mockQuizModel.findById.mockResolvedValue(sampleQuiz);
      mockSubmissionModel.countDocuments.mockResolvedValue(3); // maxAttemptsAllowed is 3

      await expect(
        service.submitAttempt(validQuizId, validUserId, { answers: [] }),
      ).rejects.toThrow(BadRequestException);
    });

    it('grades all-correct answers with 100% score and marks as passed', async () => {
      mockQuizModel.findById.mockResolvedValue(sampleQuiz);
      mockSubmissionModel.countDocuments.mockResolvedValue(0);

      const dto = {
        timeTakenSeconds: 45,
        answers: [
          { questionId: validQuestionId1, selectedOptionIds: ['opt_1'] },
          { questionId: validQuestionId2, selectedOptionIds: ['opt_1'] },
        ],
      };

      const result = await service.submitAttempt(validQuizId, validUserId, dto);

      expect(result.attemptNumber).toBe(1);
      expect(result.totalScore).toBe(20);
      expect(result.maxPossibleScore).toBe(20);
      expect(result.scorePercent).toBe(100);
      expect(result.isPassed).toBe(true);
      expect(result.answers[0].isCorrect).toBe(true);
      expect(result.answers[0].pointsAwarded).toBe(10);
      expect(result.answers[1].isCorrect).toBe(true);
      expect(result.answers[1].pointsAwarded).toBe(10);
    });

    it('grades partially correct answers and computes failing score when below passing threshold', async () => {
      mockQuizModel.findById.mockResolvedValue(sampleQuiz);
      mockSubmissionModel.countDocuments.mockResolvedValue(1);

      const dto = {
        timeTakenSeconds: 60,
        answers: [
          { questionId: validQuestionId1, selectedOptionIds: ['opt_1'] }, // correct (10 pts)
          { questionId: validQuestionId2, selectedOptionIds: ['opt_2'] }, // wrong (0 pts)
        ],
      };

      const result = await service.submitAttempt(validQuizId, validUserId, dto);

      expect(result.attemptNumber).toBe(2);
      expect(result.totalScore).toBe(10);
      expect(result.maxPossibleScore).toBe(20);
      expect(result.scorePercent).toBe(50);
      expect(result.isPassed).toBe(false); // 50% < 70% passingScorePercent
      expect(result.answers[0].isCorrect).toBe(true);
      expect(result.answers[1].isCorrect).toBe(false);
    });
  });

  describe('getUserSubmissions', () => {
    it('returns submissions sorted by attemptNumber descending', async () => {
      const mockSubmissions = [
        { attemptNumber: 2, scorePercent: 100 },
        { attemptNumber: 1, scorePercent: 50 },
      ];
      mockSubmissionModel.find.mockReturnValue({
        sort: vi.fn().mockReturnValue({
          exec: vi.fn().mockResolvedValue(mockSubmissions),
        }),
      });

      const results = await service.getUserSubmissions(validQuizId, validUserId);
      expect(results).toHaveLength(2);
      expect(results[0].attemptNumber).toBe(2);
    });
  });
});
