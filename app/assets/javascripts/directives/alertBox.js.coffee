angular.module('dahlia.directives')
.directive 'alertBox', ['$translate', '$state', ($translate, $state) ->
  restrict: 'E'
  scope:
    formObject: '=?'
    addressError: '=?'
    hideAlert: '=?'
    preferenceWarning: '=?'
    customMessage: '=?'
    customSubMessage: '=?'
    invert: '=?'
    primary: '=?'
    info: '=?'
    shortForm: '=?'
    eligibilityErrors: '=?'

  templateUrl: 'directives/alert-box.html'

  link: (scope, elem, attrs) ->
    if scope.shortForm
      # shortForm "default settings"
      scope.formObject ?= scope.$parent.form.applicationForm
      scope.hideAlert ?= scope.$parent.hideAlert
      scope.invert ?= true

    scope.showAlert = ->
      if scope.customMessage
        return scope.hideAlert == false
      if scope.addressError
        return true
      else
        form = scope.formObject
        return false unless form
        return false if form.$submitted && form.$valid
        # show alert if we've submitted an invalid form, and we haven't manually hidden it
        form.$submitted && form.$invalid && scope.hideAlert == false

    scope.alertText = ->
      if scope.customMessage
        return scope.customMessage
      else if scope.preferenceWarning
        if scope.preferenceWarning == 'preferenceNotSelected'
          $translate.instant('ERROR.PLEASE_SELECT_PREFERENCE_OPTION')
        else
          $translate.instant('ERROR.PLEASE_COMPLETE_PREFERENCE')
      else
        $translate.instant('ERROR.FORM_SUBMISSION')

    scope.close = (e) ->
      e.preventDefault()
      scope.hideAlert = true
      if scope.shortForm
        scope.$parent.hideAlert = true

    scope.contactTypeData = (contactType) ->
      {contactType: contactType}

    scope.getStyles = ->
      styles = ''
      if scope.invert
        styles += 'invert no-margin '
      if scope.primary
        styles += 'primary '
        unless scope.info
          styles += 'no-icon '
      styles

    scope.isIconInverted = ->
      if !scope.invert
        return 'i-oil'

]
