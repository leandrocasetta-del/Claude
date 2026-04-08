package com.galaxycleaner.app.ui.albums

import android.Manifest
import android.app.AlertDialog
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.galaxycleaner.app.adapter.AlbumAdapter
import com.galaxycleaner.app.databinding.FragmentAlbumsBinding
import com.galaxycleaner.app.databinding.DialogSaveMacroBinding
import com.galaxycleaner.app.model.Album
import com.galaxycleaner.app.model.MacroAction
import com.galaxycleaner.app.service.AlbumManager
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.launch

class AlbumsFragment : Fragment() {

    private var _binding: FragmentAlbumsBinding? = null
    private val binding get() = _binding!!

    private lateinit var albumManager: AlbumManager
    private lateinit var albumAdapter: AlbumAdapter
    private var allAlbums: List<Album> = emptyList()

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        if (permissions.values.any { it }) {
            loadAlbums()
        } else {
            showPermissionDenied()
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentAlbumsBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        albumManager = AlbumManager(requireContext())
        setupRecyclerView()
        setupSearch()
        setupFabs()
        checkPermissionsAndLoad()
    }

    private fun setupRecyclerView() {
        albumAdapter = AlbumAdapter(
            onToggleVisibility = { album -> toggleAlbumVisibility(album) },
            onSelectionChanged = { _, _ -> updateSelectionCount() }
        )
        binding.recyclerAlbums.apply {
            adapter = albumAdapter
            layoutManager = LinearLayoutManager(requireContext())
        }
    }

    private fun setupSearch() {
        binding.searchBar.editText?.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                filterAlbums(s?.toString() ?: "")
            }
            override fun afterTextChanged(s: Editable?) {}
        })
    }

    private fun setupFabs() {
        binding.fabMacro.setOnClickListener {
            enterSelectionMode()
        }

        binding.btnCancelSelection.setOnClickListener {
            exitSelectionMode()
        }

        binding.btnSelectAll.setOnClickListener {
            albumAdapter.selectAll()
            updateSelectionCount()
        }

        binding.fabHideSelected.setOnClickListener {
            hideSelectedAlbums()
        }

        binding.fabShowSelected.setOnClickListener {
            showSelectedAlbums()
        }

        binding.fabSaveMacro.setOnClickListener {
            showSaveMacroDialog()
        }
    }

    private fun enterSelectionMode() {
        albumAdapter.selectionMode = true
        binding.selectionToolbar.visibility = View.VISIBLE
        binding.fabMacro.visibility = View.GONE
        binding.layoutSelectionActions.visibility = View.VISIBLE
        updateSelectionCount()
    }

    private fun exitSelectionMode() {
        albumAdapter.selectionMode = false
        binding.selectionToolbar.visibility = View.GONE
        binding.fabMacro.visibility = View.VISIBLE
        binding.layoutSelectionActions.visibility = View.GONE
    }

    private fun updateSelectionCount() {
        val count = albumAdapter.getSelectedPaths().size
        binding.tvSelectionCount.text = "$count selecionado(s)"
    }

    private fun checkPermissionsAndLoad() {
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            arrayOf(
                Manifest.permission.READ_MEDIA_IMAGES,
                Manifest.permission.READ_MEDIA_VIDEO
            )
        } else {
            arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
        }

        val allGranted = permissions.all {
            ContextCompat.checkSelfPermission(requireContext(), it) == PackageManager.PERMISSION_GRANTED
        }

        if (allGranted) {
            loadAlbums()
        } else {
            permissionLauncher.launch(permissions)
        }
    }

    private fun loadAlbums() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                allAlbums = albumManager.loadAlbums()
                filterAlbums(binding.searchBar.text?.toString() ?: "")
                binding.layoutEmpty.visibility = if (allAlbums.isEmpty()) View.VISIBLE else View.GONE
            } catch (e: Exception) {
                Snackbar.make(binding.root, "Erro ao carregar albums: ${e.message}", Snackbar.LENGTH_LONG).show()
            }
        }
    }

    private fun filterAlbums(query: String) {
        val filtered = if (query.isBlank()) allAlbums
        else allAlbums.filter { it.name.contains(query, ignoreCase = true) }
        albumAdapter.submitList(filtered)
    }

    private fun toggleAlbumVisibility(album: Album) {
        viewLifecycleOwner.lifecycleScope.launch {
            val success = albumManager.toggleAlbumVisibility(album)
            if (success) {
                val msg = if (album.isHidden) "${album.name} agora visivel"
                else "${album.name} ocultado"
                Snackbar.make(binding.root, msg, Snackbar.LENGTH_SHORT).show()
                loadAlbums()
            } else {
                Snackbar.make(binding.root, "Erro ao alterar visibilidade do album", Snackbar.LENGTH_SHORT).show()
            }
        }
    }

    private fun hideSelectedAlbums() {
        val paths = albumAdapter.getSelectedPaths()
        if (paths.isEmpty()) {
            Snackbar.make(binding.root, "Selecione ao menos um album", Snackbar.LENGTH_SHORT).show()
            return
        }
        viewLifecycleOwner.lifecycleScope.launch {
            val count = albumManager.hideAlbums(paths)
            Snackbar.make(binding.root, "$count album(ns) ocultado(s)", Snackbar.LENGTH_SHORT).show()
            exitSelectionMode()
            loadAlbums()
        }
    }

    private fun showSelectedAlbums() {
        val paths = albumAdapter.getSelectedPaths()
        if (paths.isEmpty()) {
            Snackbar.make(binding.root, "Selecione ao menos um album", Snackbar.LENGTH_SHORT).show()
            return
        }
        viewLifecycleOwner.lifecycleScope.launch {
            val count = albumManager.showAlbums(paths)
            Snackbar.make(binding.root, "$count album(ns) tornado(s) visivel(is)", Snackbar.LENGTH_SHORT).show()
            exitSelectionMode()
            loadAlbums()
        }
    }

    private fun showSaveMacroDialog() {
        val paths = albumAdapter.getSelectedPaths()
        if (paths.isEmpty()) {
            Snackbar.make(binding.root, "Selecione ao menos um album para criar a macro", Snackbar.LENGTH_SHORT).show()
            return
        }

        val dialogBinding = DialogSaveMacroBinding.inflate(layoutInflater)
        dialogBinding.toggleAction.check(dialogBinding.btnActionHide.id)

        val dialog = MaterialAlertDialogBuilder(requireContext())
            .setView(dialogBinding.root)
            .create()

        dialogBinding.btnCancelMacro.setOnClickListener { dialog.dismiss() }
        dialogBinding.btnConfirmMacro.setOnClickListener {
            val name = dialogBinding.etMacroName.text?.toString()?.trim() ?: ""
            if (name.isEmpty()) {
                dialogBinding.tilMacroName.error = getString(com.galaxycleaner.app.R.string.macro_name_empty)
                return@setOnClickListener
            }
            val action = if (dialogBinding.toggleAction.checkedButtonId == dialogBinding.btnActionHide.id)
                MacroAction.HIDE else MacroAction.SHOW

            albumManager.saveMacroPreset(name, paths, action)
            dialog.dismiss()
            exitSelectionMode()
            Snackbar.make(binding.root, getString(com.galaxycleaner.app.R.string.macro_saved), Snackbar.LENGTH_SHORT).show()
        }

        dialog.show()
    }

    private fun showPermissionDenied() {
        Snackbar.make(binding.root, getString(com.galaxycleaner.app.R.string.permission_required), Snackbar.LENGTH_LONG)
            .setAction(getString(com.galaxycleaner.app.R.string.grant_permission)) {
                checkPermissionsAndLoad()
            }.show()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
