import os
import tempfile
from fastapi import APIRouter, File, Request, Response, UploadFile

from app.api.dependencies.files import validate_upload
from app.core.exceptions import AnalysisError, ParsingError
from app.models.schemas import AnalysisResponse
from app.services.ats_scorer import ATSScorer
from app.services.domain_classifier import DomainClassifier
from app.services.report_generator import ReportGenerator
from app.services.resume_parser import ResumeParser
from app.services.skill_extractor import SkillExtractor

router = APIRouter(tags=['analysis'])

resume_parser = ResumeParser()
ats_scorer = ATSScorer()
skill_extractor = SkillExtractor()
domain_classifier = DomainClassifier()
report_generator = ReportGenerator()


@router.post('/api/analyze', response_model=AnalysisResponse)
async def analyze_resume(file: UploadFile = File(...)):
    file_content = validate_upload(file)
    file_extension = os.path.splitext(file.filename or '')[1].lower()

    temp_path = None
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=file_extension) as tmp_file:
            tmp_file.write(file_content)
            temp_path = tmp_file.name

        parsed_data = resume_parser.parse(temp_path, file_extension)
        parsing_method = parsed_data.get('parsing_method', 'standard')
        ocr_confidence = parsed_data.get('ocr_confidence')

        skills_data = skill_extractor.extract(parsed_data['raw_text'])
        domain_data = domain_classifier.classify(parsed_data['raw_text'], skills_data)
        ats_analysis = ats_scorer.calculate_score(
            parsed_data,
            skills_data,
            domain_data,
            parsing_method=parsing_method,
            ocr_confidence=ocr_confidence,
        )

        return AnalysisResponse(
            success=True,
            candidate=parsed_data['candidate'],
            ats_score=ats_analysis['score'],
            score_breakdown=ats_analysis['breakdown'],
            score_category=ats_analysis['category'],
            domain=domain_data,
            skills=skills_data,
            projects=parsed_data['projects'],
            experience=parsed_data['experience'],
            education=parsed_data['education'],
            issues=ats_analysis['issues'],
            suggestions=ats_analysis['suggestions'],
            keywords_analysis=ats_analysis['keywords_analysis'],
            parsing_method=parsing_method,
            ocr_confidence=ocr_confidence,
        )
    except (ParsingError, AnalysisError) as exc:
        raise exc
    except Exception as exc:
        raise AnalysisError(str(exc)) from exc
    finally:
        if temp_path and os.path.exists(temp_path):
            os.unlink(temp_path)


@router.post('/api/download-report')
async def download_report(request: Request):
    try:
        analysis_data = await request.json()
    except Exception as exc:
        raise AnalysisError('Invalid report payload') from exc

    try:
        pdf_bytes = report_generator.generate_pdf(analysis_data)
        return Response(
            content=pdf_bytes,
            media_type='application/pdf',
            headers={'Content-Disposition': 'attachment; filename=ats-resume-report.pdf'},
        )
    except Exception as exc:
        raise AnalysisError('Failed to generate report') from exc
