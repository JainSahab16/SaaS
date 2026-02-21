import pathlib
from django.http import HttpResponse
from django.shortcuts import render

from visits.models import PageVisit
this_dir=pathlib.Path(__file__).resolve().parent


def home_page_view(request,*args,**kwargs):
   qs = PageVisit.objects.all()
   page_qs=PageVisit.objects.filter(path=request.path)
   my_title="My Page"
   my_context={
      "page_title":my_title,
      "queryset":page_qs.count(),
      "total_visit_count":qs.count(),
   }
   html_template="home.html"
   path=request.path
   print(path)
   PageVisit.objects.create(path=request.path)
   return render(request,html_template,my_context)


def about_page_view(request,*args,**kwargs):
   my_title="My page"
   my_context={
      "page_title":my_title
   }
   html_template="about.html"
   return render(request,html_template,my_context)