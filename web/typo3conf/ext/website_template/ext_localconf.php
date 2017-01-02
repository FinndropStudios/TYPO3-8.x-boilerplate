<?php

/**
 * @var $_EXTKEY string
 */

if(!defined('TYPO3_MODE')) {
	die('Access denied.');
}

/*****
 * Page TS
 */
\TYPO3\CMS\Core\Utility\ExtensionManagementUtility::addPageTSConfig('<INCLUDE_TYPOSCRIPT: source="FILE:EXT:' . $_EXTKEY . '/Configuration/PageTypoScript/page_ts.t3s">');
